// variables.tf
variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}
variable "vpc_cidr_block" {
  description = "CIDR block for the primary VPC"
  type        = string
  default     = "10.0.0.0/16"
}
variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}
variable "availability_zone" {
  description = "AZ in which to create the public subnet"
  type        = string
  default     = "us-east-1a"
}
variable "ami_name_filter" {
  description = "Filter to find the latest Amazon Linux 2 AMI"
  type        = string
  default     = "amzn2-ami-hvm-*-gp2"
}
variable "instance_type" {
  description = "EC2 instance type for Jenkins server"
  type        = string
  default     = "t2.large"
}
variable "root_volume_size" {
  description = "Root EBS volume size for Jenkins (GB)"
  type        = number
  default     = 30
}
variable "my_ip" {
  description = "Your IP CIDR block for SSH access"
  type        = string
  default     = "203.0.113.0/32"
}
