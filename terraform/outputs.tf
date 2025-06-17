// outputs.tf
#────────────────────────────────────────────────────────────────
# Outputs for user convenience
#────────────────────────────────────────────────────────────────

output "private_key_path" {
  description = "Path to the generated SSH private key"
  value       = local_file.private_key_pem.filename
}

output "instance_public_ip" {
  description = "Public IP of Jenkins EC2"
  value       = aws_instance.jenkins.public_ip
}

output "jenkins_url" {
  description = "Jenkins access URL"
  value       = "http://${aws_instance.jenkins.public_ip}:8080"
}

output "sonarqube_url" {
  description = "SonarQube access URL"
  value       = "http://${aws_instance.jenkins.public_ip}:9000"
}

output "react_app_url" {
  description = "React app access URL"
  value       = "http://${aws_instance.jenkins.public_ip}:3000"
}
