resource "aws_security_group" "jenkins_sg" {
  name        = "Jenkins-Security-Group"
  description = "Allow traffic for SSH, HTTP, HTTPS, Jenkins, SonarQube, and React app"

  # SSH Access (limit to your IP for better security)
  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.my_ip]  # Replace with your actual IP address
    description      = "Allow SSH access"
  }

  # HTTP Access (port 80, React or other web apps)
  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]  # Change to trusted IPs for better security
    description      = "Allow HTTP access"
  }

  # HTTPS Access (port 443, for SSL/TLS traffic)
  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]  # Change to trusted IPs for better security
    description      = "Allow HTTPS access"
  }

  # Jenkins Access (port 8080)
  ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]  # Ideally, limit this to trusted IPs or ranges
    description      = "Allow Jenkins access"
  }

  # SonarQube Access (port 9000)
  ingress {
    from_port        = 9000
    to_port          = 9000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]  # Ideally, limit this to trusted IPs or ranges
    description      = "Allow SonarQube access"
  }

  # React App Access (port 3000)
  ingress {
    from_port        = 3000
    to_port          = 3000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]  # Change to trusted IPs for better security
    description      = "Allow React app access"
  }

  # Allow all outbound traffic (egress)
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Jenkins-SG"
  }
}

resource "aws_instance" "jenkins_instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  user_data              = templatefile("${path.module}/jenkins/install_jenkins.sh", {})

  tags = {
    Name = "Jenkins-Instance"
  }

  root_block_device {
    volume_size = 30  # Set appropriate size (<=30 GB for free-tier)
  }
}