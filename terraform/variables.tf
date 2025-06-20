// variables.tf
variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
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
variable "my_ip" {
  description = "Your IP CIDR block for SSH access"
  type        = string
  default     = "203.0.113.0/32" // change to your own private IP address
}
