#!/usr/bin/env bash
set -euo pipefail

#────────────────────────────────────────────────────────────────
# 1. Update OS and Install Java 17 (Amazon Corretto)
#────────────────────────────────────────────────────────────────
echo "[INFO] Updating system..."
sudo yum update -y

echo "[INFO] Installing Amazon Corretto 17..."
sudo yum install -y java-17-amazon-corretto

#────────────────────────────────────────────────────────────────
# 2. Install Jenkins
#────────────────────────────────────────────────────────────────
echo "[INFO] Adding Jenkins repository..."
sudo wget -O /etc/yum.repos.d/jenkins.repo \
  https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

echo "[INFO] Installing Jenkins..."
sudo yum install -y jenkins

echo "[INFO] Enabling and starting Jenkins..."
sudo systemctl enable --now jenkins

#────────────────────────────────────────────────────────────────
# 3. Install Docker
#────────────────────────────────────────────────────────────────
echo "[INFO] Installing Docker..."
sudo amazon-linux-extras install -y docker

echo "[INFO] Enabling and starting Docker..."
sudo systemctl enable --now docker

echo "[INFO] Adding 'ec2-user' to docker group..."
sudo usermod -aG docker ec2-user

#────────────────────────────────────────────────────────────────
# 4. Deploy SonarQube (Docker container)
#────────────────────────────────────────────────────────────────
echo "[INFO] Running SonarQube container..."
sudo docker run -d --name sonar \
  -p 9000:9000 \
  sonarqube:lts-community

#────────────────────────────────────────────────────────────────
# 5. Install Trivy (Static & Image Scanner)
#────────────────────────────────────────────────────────────────
echo "[INFO] Installing Trivy..."
TRIVY_VERSION=$(curl -s https://api.github.com/repos/aquasecurity/trivy/releases/latest \
  | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
curl -sL https://github.com/aquasecurity/trivy/releases/download/${TRIVY_VERSION}/trivy_${TRIVY_VERSION#v}_Linux-64bit.tar.gz \
  | sudo tar xz -C /usr/local/bin --strip-components=1 trivy

echo "[INFO] Verifying installations..."
java --version
sudo systemctl status jenkins --no-pager
docker ps
trivy --version

echo "[INFO] Jenkins bootstrap complete. Access Jenkins at port 8080, SonarQube at 9000." 
