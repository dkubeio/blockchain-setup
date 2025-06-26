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
  - docker.io
  - docker-compose

runcmd:
  # Start and enable Docker
  - systemctl start docker
  - systemctl enable docker
  
  # Add user to docker group
  - usermod -aG docker ${admin_username}
  
  # Install Azure CLI
  - curl -sL https://aka.ms/InstallAzureCLIDeb | bash
  
  # Install CCF Python package
  - pip3 install ccf
  
  # Create directory for CCF client
  - mkdir -p /home/${admin_username}/ccf-client
  - chown -R ${admin_username}:${admin_username} /home/${admin_username}/ccf-client
  
  # Set up environment variables
  - echo 'export CCF_CLIENT_DIR=/home/${admin_username}/ccf-client' >> /home/${admin_username}/.bashrc
  - echo 'export PATH=$PATH:/home/${admin_username}/.local/bin' >> /home/${admin_username}/.bashrc

final_message: "CCF VM setup completed successfully!" 