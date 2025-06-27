#cloud-config
package_update: true
package_upgrade: true

packages:
  - curl
  - wget
  - git
  - build-essential
  - python3
  - python3-pip
  - nodejs
  - npm
  - apt-transport-https
  - ca-certificates
  - gnupg
  - lsb-release

runcmd:
  # Install Docker
  - curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  - echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
  - apt-get update
  - apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  
  # Start and enable Docker
  - systemctl start docker
  - systemctl enable docker
  
  # Add user to docker group
  - usermod -aG docker ${admin_username}
  
  # Install Azure CLI
  - curl -sL https://aka.ms/InstallAzureCLIDeb | bash
  
  # Set up environment variables including OpenAI API key
  - echo 'export PATH=$PATH:/home/${admin_username}/.local/bin' >> /home/${admin_username}/.bashrc
  - echo 'export OPENAI_API_KEY=${openai_api_key}' >> /home/${admin_username}/.bashrc
  
  # Also set OpenAI API key in system environment
  - echo 'OPENAI_API_KEY=${openai_api_key}' >> /etc/environment

final_message: "VM setup completed successfully!" 