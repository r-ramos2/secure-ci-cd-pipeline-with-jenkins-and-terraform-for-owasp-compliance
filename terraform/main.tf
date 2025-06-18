// main.tf
#────────────────────────────────────────────────────────────────
# Locals for project naming & tagging
#────────────────────────────────────────────────────────────────
locals {
  project_name = "aws-devsecops-homelab"
  common_tags  = {
    Project = local.project_name
  }
}

#────────────────────────────────────────────────────────────────
# 1. SSH Keypair Generation
#────────────────────────────────────────────────────────────────
resource "tls_private_key" "deployer" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_key_pair" "deployer" {
  key_name   = "${local.project_name}-${random_id.suffix.hex}"
  public_key = tls_private_key.deployer.public_key_openssh
}

resource "local_file" "private_key_pem" {
  content         = tls_private_key.deployer.private_key_pem
  filename        = "${path.module}/deployer_key.pem"
  file_permission = "0400"
}

#────────────────────────────────────────────────────────────────
# 2. AMI Data Source (latest Amazon Linux 2)
#────────────────────────────────────────────────────────────────
data "aws_ami" "linux2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = [var.ami_name_filter]
  }
}

#────────────────────────────────────────────────────────────────
# 3. Networking: VPC, Subnet, IGW, Routing
#────────────────────────────────────────────────────────────────
resource "aws_vpc" "lab" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, { Name = "${local.project_name}-vpc" })
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, { Name = "${local.project_name}-subnet" })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.lab.id
  tags   = merge(local.common_tags, { Name = "${local.project_name}-igw" })
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.lab.id
  tags   = merge(local.common_tags, { Name = "${local.project_name}-rt" })
}

resource "aws_route" "default" {
  route_table_id         = aws_route_table.rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.rt.id
}

#────────────────────────────────────────────────────────────────
# 4. Security Group for Jenkins & App
#────────────────────────────────────────────────────────────────
resource "aws_security_group" "jenkins_sg" {
  name        = "${local.project_name}-sg"
  description = "Allow SSH, HTTP, HTTPS, Jenkins, SonarQube, React App"
  vpc_id      = aws_vpc.lab.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }
  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Jenkins port
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # SonarQube port
  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # React App port
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${local.project_name}-sg" })
}

#────────────────────────────────────────────────────────────────
# 5. EC2 Instance (Jenkins, Docker, SonarQube, Trivy)
#────────────────────────────────────────────────────────────────
resource "aws_instance" "jenkins" {
  ami                         = data.aws_ami.linux2.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.deployer.key_name
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  associate_public_ip_address = true

  # User data to bootstrap Jenkins, Docker, SonarQube, Trivy
  user_data = file("${path.module}/../jenkins/install_jenkins.sh")

  root_block_device {
    volume_size = 30
  }

  tags = merge(local.common_tags, { Name = "${local.project_name}-jenkins" })
}
