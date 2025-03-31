#!/bin/bash

# Exit immediately if any command fails
set -e

# Update the system
echo "Updating system..."
sudo dnf update -y

# Install Java (Jenkins requires Java, Amazon Corretto is a good choice)
echo "Installing Java (Amazon Corretto)..."
sudo dnf install -y java-17-amazon-corretto
java --version  # Confirm Java installation

# Install Jenkins
echo "Installing Jenkins..."
sudo dnf install -y wget
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo dnf upgrade -y
sudo dnf install -y jenkins
sudo systemctl enable --now jenkins
sudo systemctl status jenkins || { echo "Jenkins failed to start"; exit 1; }

# Jenkins should be running now. The default port for Jenkins is 8080.
echo "Jenkins is now installed and running on port 8080."

# Install Docker
echo "Installing Docker..."
sudo dnf install -y docker
sudo systemctl enable --now docker
sudo systemctl start docker

# Install SonarQube (Docker-based)
echo "Installing SonarQube..."
sudo docker run -d --name sonar -p 9000:9000 sonarqube:lts-community

# Install Trivy (Container security scanner)
echo "Installing Trivy..."
sudo dnf install -y wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo dnf update -y
sudo dnf install -y trivy
