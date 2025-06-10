# Get available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# Create VPC
resource "aws_vpc" "blockchain_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "${var.resource_prefix}-vpc"
  })
}

# Create public subnet
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.blockchain_vpc.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(var.tags, {
    Name = "${var.resource_prefix}-public-subnet-${count.index + 1}"
  })
}

# Create private subnet
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.blockchain_vpc.id
  cidr_block        = "10.0.${count.index + 10}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(var.tags, {
    Name = "${var.resource_prefix}-private-subnet-${count.index + 1}"
  })
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.blockchain_vpc.id

  tags = merge(var.tags, {
    Name = "${var.resource_prefix}-igw"
  })
}

# Create Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = merge(var.tags, {
    Name = "${var.resource_prefix}-nat-eip"
  })
}

# Create NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(var.tags, {
    Name = "${var.resource_prefix}-nat"
  })

  depends_on = [aws_internet_gateway.igw]
}

# Create route tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.blockchain_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(var.tags, {
    Name = "${var.resource_prefix}-public-rt"
  })
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.blockchain_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = merge(var.tags, {
    Name = "${var.resource_prefix}-private-rt"
  })
}

# Create route table associations
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Create security groups
resource "aws_security_group" "vpc_endpoint" {
  name        = "${var.resource_prefix}-managedblockchain-endpoint-sg"
  description = "Security group for Managed Blockchain VPC Endpoint"
  vpc_id      = aws_vpc.blockchain_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Allow HTTPS from VPC"
  }

  ingress {
    from_port   = 30001
    to_port     = 30003
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Allow Managed Blockchain ports from VPC"
  }

  ingress {
    from_port   = 30001
    to_port     = 30003
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24"]  # Public subnet CIDRs
    description = "Allow Managed Blockchain ports from public subnets"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(var.tags, {
    Name = "${var.resource_prefix}-vpc-endpoint-sg"
  })
}

resource "aws_security_group" "client" {
  name        = "${var.resource_prefix}-client-sg"
  description = "Security group for blockchain client EC2 instance"
  vpc_id      = aws_vpc.blockchain_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
    description = "SSH access"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access"
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Application access"
  }

  ingress {
    from_port   = 8000
    to_port     = 8085
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Application port range access"
  }

  ingress {
    from_port   = 30001
    to_port     = 30003
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow Managed Blockchain ports"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(var.tags, {
    Name = "${var.resource_prefix}-client-sg"
  })
}

# Create security group for blockchain nodes
resource "aws_security_group" "blockchain" {
  name        = "${var.resource_prefix}-blockchain-sg"
  description = "Security group for blockchain nodes"
  vpc_id      = aws_vpc.blockchain_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
    description = "Allow all traffic from within VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
    description = "Allow all outbound traffic within VPC"
  }

  tags = merge(var.tags, {
    Name = "${var.resource_prefix}-blockchain-sg"
  })
} 