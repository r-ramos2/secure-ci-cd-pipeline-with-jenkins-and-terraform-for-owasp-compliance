#!/bin/bash
set -e

#────────────────────────────────────────────────────────────────
# 1. Update OS and install prerequisites
#────────────────────────────────────────────────────────────────
echo "[INFO] Updating system and installing prerequisites..."
sudo yum update -y
sudo amazon-linux-extras install java-openjdk11 -y
sudo yum install git wget unzip -y

#────────────────────────────────────────────────────────────────
# 2. Install Docker
#────────────────────────────────────────────────────────────────
echo "[INFO] Installing Docker..."
sudo amazon-linux-extras install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user

#────────────────────────────────────────────────────────────────
# 3. Install Jenkins
#────────────────────────────────────────────────────────────────
echo "[INFO] Installing Jenkins..."
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins

#────────────────────────────────────────────────────────────────
# 4. Run SonarQube in Docker
#────────────────────────────────────────────────────────────────
echo "[INFO] Deploying SonarQube container..."
sudo docker pull sonarqube:lts
sudo docker run -d --name sonarqube -p 9000:9000 sonarqube:lts

#────────────────────────────────────────────────────────────────
# 5. Install Trivy (Static & Image Scanner)
#────────────────────────────────────────────────────────────────
echo "[INFO] Installing Trivy..."
TRIVY_VERSION=$(curl -s https://api.github.com/repos/aquasecurity/trivy/releases/latest \
  | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
ARCHIVE="trivy_${TRIVY_VERSION#v}_Linux-64bit.tar.gz"

# download & extract
curl -sL "https://github.com/aquasecurity/trivy/releases/download/${TRIVY_VERSION}/${ARCHIVE}" \
  -o "/tmp/${ARCHIVE}"
tar zxvf "/tmp/${ARCHIVE}" -C /tmp trivy
sudo mv /tmp/trivy /usr/local/bin/trivy
sudo chmod +x /usr/local/bin/trivy
rm "/tmp/${ARCHIVE}"

#────────────────────────────────────────────────────────────────
# 6. Verify installations
#────────────────────────────────────────────────────────────────
echo "[INFO] Verifying installations..."
java --version
sudo systemctl status jenkins --no-pager
docker ps
which trivy || { echo 'ERROR: trivy not found in PATH'; exit 1; }
trivy --version

#────────────────────────────────────────────────────────────────
# Done
#────────────────────────────────────────────────────────────────
echo "[INFO] Jenkins bootstrap complete."
echo "[INFO] Access Jenkins at port 8080, SonarQube at port 9000."
