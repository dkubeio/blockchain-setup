terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.13.1"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "time" {}

provider "null" {}

# Generate random password for admin
resource "random_password" "admin_password" {
  length           = 16
  special          = false
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
}

locals {
  admin_password = var.admin_password != null ? var.admin_password : random_password.admin_password.result
}

# Create network infrastructure
module "network" {
  source = "./modules/network"

  vpc_cidr        = var.vpc_cidr
  ssh_cidr        = var.ssh_cidr
  resource_prefix = var.resource_prefix
  tags            = var.tags
}

# Create Managed Blockchain network using AWS CLI
resource "null_resource" "fabric_network" {
  triggers = {
    network_name = var.network_name
    member_name  = var.member_name
    admin_password = local.admin_password
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Check if network already exists
      EXISTING_NETWORK=$(aws managedblockchain list-networks \
        --region "${var.aws_region}" \
        --query "Networks[?Name=='${var.network_name}'].Id" \
        --output text)
      
      if [ -z "$EXISTING_NETWORK" ]; then
        echo "Creating new network..."
        aws managedblockchain create-network \
          --name "${var.network_name}" \
          --description "Hyperledger Fabric Network" \
          --framework HYPERLEDGER_FABRIC \
          --framework-version "2.2" \
          --framework-configuration '{
            "Fabric": {
              "Edition": "STANDARD"
            }
          }' \
          --voting-policy '{
            "ApprovalThresholdPolicy": {
              "ThresholdPercentage": 50,
              "ProposalDurationInHours": 24,
              "ThresholdComparator": "GREATER_THAN_OR_EQUAL_TO"
            }
          }' \
          --member-configuration '{
            "Name": "${var.member_name}",
            "Description": "First member of the network",
            "FrameworkConfiguration": {
              "Fabric": {
                "AdminUsername": "${var.admin_username}",
                "AdminPassword": "${local.admin_password}"
              }
            }
          }' \
          --region "${var.aws_region}"
      else
        echo "Network '${var.network_name}' already exists with ID: $EXISTING_NETWORK"
      fi
    EOT
  }
}

# Wait for 40 minutes for the network to be fully provisioned
resource "time_sleep" "wait_for_network" {
  depends_on = [null_resource.fabric_network]
  create_duration = "40m"
}

# Get network ID using AWS CLI
data "external" "network_info" {
  depends_on = [time_sleep.wait_for_network]
  
  program = ["bash", "-c", <<-EOT
    # Get the network ID
    NETWORK_ID=$(aws managedblockchain list-networks \
      --region "${var.aws_region}" \
      --query "Networks[?Name=='${var.network_name}'].Id" \
      --output text)
    
    # Get the member ID
    MEMBER_ID=$(aws managedblockchain list-members \
      --region "${var.aws_region}" \
      --network-id $NETWORK_ID \
      --query "Members[?Name=='${var.member_name}'].Id" \
      --output text)
    
    # Output as JSON with proper escaping
    printf '{"network_id":"%s","member_id":"%s"}' "$NETWORK_ID" "$MEMBER_ID"
  EOT
  ]
}

# Create peer node using AWS CLI
resource "null_resource" "create_peer" {
  depends_on = [time_sleep.wait_for_network, data.external.network_info]

  triggers = {
    network_id = data.external.network_info.result.network_id
    member_id  = data.external.network_info.result.member_id
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Check if peer node already exists
      EXISTING_PEER=$(aws managedblockchain list-nodes \
        --network-id ${data.external.network_info.result.network_id} \
        --member-id ${data.external.network_info.result.member_id} \
        --region "${var.aws_region}" \
        --query "Nodes[0].Id" \
        --output text)
      
      if [ -z "$EXISTING_PEER" ] || [ "$EXISTING_PEER" == "None" ]; then
        echo "Checking if network is ready..."
        while true; do
          NETWORK_STATUS=$(aws managedblockchain get-network \
            --network-id ${data.external.network_info.result.network_id} \
            --region "${var.aws_region}" \
            --query "Network.Status" \
            --output text)
          
          if [ "$NETWORK_STATUS" == "AVAILABLE" ]; then
            echo "Network is ready. Creating new peer node..."
            aws managedblockchain create-node \
              --network-id ${data.external.network_info.result.network_id} \
              --member-id ${data.external.network_info.result.member_id} \
              --node-configuration '{
                "InstanceType": "bc.t3.small",
                "AvailabilityZone": "${var.aws_region}a",
                "StateDB": "LevelDB"
              }' \
              --region "${var.aws_region}"
            break
          else
            echo "Network status: $NETWORK_STATUS. Waiting for network to be ready..."
            sleep 30
          fi
        done
      else
        echo "Peer node already exists with ID: $EXISTING_PEER"
      fi
    EOT
  }
}

# Cleanup Managed Blockchain resources
resource "null_resource" "cleanup_blockchain" {
  depends_on = [null_resource.create_peer]

  triggers = {
    network_id = data.external.network_info.result.network_id
    member_id  = data.external.network_info.result.member_id
    region     = var.aws_region
  }

  # This will run during terraform destroy
  provisioner "local-exec" {
    when = destroy

    command = <<-EOT
      # Delete the member
      echo "Deleting member ${self.triggers.member_id}..."
      aws managedblockchain delete-member \
        --network-id ${self.triggers.network_id} \
        --member-id ${self.triggers.member_id} \
        --region "${self.triggers.region}"
      
      # Wait for member deletion
      echo "Waiting for member ${self.triggers.member_id} to be deleted..."
      while true; do
        if ! aws managedblockchain list-members \
          --network-id ${self.triggers.network_id} \
          --region "${self.triggers.region}" \
          --query "Members[?Id=='${self.triggers.member_id}']" \
          --output text | grep -q "${self.triggers.member_id}"; then
          echo "Member has been deleted"
          break
        fi
        echo "Member still exists, waiting..."
        sleep 30
      done
    EOT
  }
}

# Wait for 10 minutes for the peer to be fully provisioned
resource "time_sleep" "wait_for_peer" {
  depends_on = [null_resource.create_peer]
  create_duration = "10m"
}

# Create VPC Endpoint for Managed Blockchain
resource "aws_vpc_endpoint" "managedblockchain" {
  depends_on = [
    module.network,
    time_sleep.wait_for_network,
    time_sleep.wait_for_peer,
    data.external.network_info
  ]
  
  vpc_id              = module.network.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.managedblockchain.${lower(data.external.network_info.result.network_id)}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.network.private_subnet_ids
  security_group_ids  = [module.network.vpc_endpoint_sg_id]
  
  private_dns_enabled = true

  tags = merge(var.tags, {
    Name = "${var.resource_prefix}-vpc-endpoint"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Create IAM role for EC2 instance
resource "aws_iam_role" "ec2_role" {
  name = "${var.resource_prefix}-ec2-role-${formatdate("YYYYMMDDHHmmss", timestamp())}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Create IAM policy for Managed Blockchain access
resource "aws_iam_policy" "managedblockchain_policy" {
  name        = "fabric-${var.resource_prefix}-managedblockchain-policy-${formatdate("YYYYMMDDHHmmss", timestamp())}"
  description = "Policy for Managed Blockchain access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "managedblockchain:*",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcEndpoints",
          "ec2:DescribeVpcEndpointServices",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "managedblockchain_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.managedblockchain_policy.arn
}

# Create instance profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.resource_prefix}-ec2-profile-${formatdate("YYYYMMDDHHmmss", timestamp())}"
  role = aws_iam_role.ec2_role.name
}

# Create Elastic IP
resource "aws_eip" "client_eip" {
  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${var.resource_prefix}-client-eip"
  })
}

# Create EC2 instance for client
resource "aws_instance" "client" {
  depends_on = [
    aws_vpc_endpoint.managedblockchain,
    module.network,
    time_sleep.wait_for_network,
    aws_eip.client_eip
  ]
  
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  subnet_id     = module.network.public_subnet_ids[0]
  vpc_security_group_ids = [module.network.client_sg_id]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  key_name      = var.ssh_key_name

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  user_data = base64encode(<<-EOT
#!/bin/bash

# Create log file
LOG_FILE="/home/ec2-user/blockchain-setup.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "Starting blockchain setup at $(date)" | tee -a "$LOG_FILE"

# Add environment variables to .bash_profile
cat >> /home/ec2-user/.bash_profile << EOPROFILE
# Base environment variables
export AWS_REGION="${var.aws_region}"
export NETWORK_NAME="${var.network_name}"
export MEMBER_NAME="${var.member_name}"
export ADMIN_USERNAME="${var.admin_username}"
export ADMIN_PASSWORD="${local.admin_password}"
export CHAINCODE_NAME="${var.chaincode_name}"
export VM_IP="${aws_eip.client_eip.public_ip}"
export OPENAI_API_KEY="${var.openai_api_key}"
export LOG_FILE="/home/ec2-user/blockchain-setup.log"
EOPROFILE

# Source the profile to make variables available
source ~/.bash_profile

# Debug: Print environment variables (excluding sensitive data)
echo "Environment variables set:"
env | grep -v "PASSWORD\|KEY" | sort

# Install Docker
echo "Installing Docker..."
sudo yum update -y
sudo yum install -y docker git
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

# Debug: Verify Docker installation
echo "Verifying Docker installation..."
docker --version

# Clone the repository using GitHub token
echo "Cloning repository..."
cd /home/ec2-user
git clone -b ${var.github_ref} https://${var.github_token}@github.com/${var.github_repo}.git
REPO_DIR=$(echo ${var.github_repo} | cut -d'/' -f2)

# Execute the user data script
echo "Starting blockchain setup script..."
cp $REPO_DIR/scripts/ec2-client/* .
chmod +x blockchain_client_setup.sh
./blockchain_client_setup.sh
EOT
  )

  tags = merge(var.tags, {
    Name = "${var.resource_prefix}-client"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Associate Elastic IP with EC2 instance
resource "aws_eip_association" "client_eip_assoc" {
  instance_id   = aws_instance.client.id
  allocation_id = aws_eip.client_eip.id
}
