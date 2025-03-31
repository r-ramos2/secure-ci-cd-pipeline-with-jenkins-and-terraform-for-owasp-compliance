output "instance_public_ip" {
  description = "Public IP address of the Jenkins EC2 instance"
  value       = aws_instance.jenkins_instance.public_ip
}

output "jenkins_url" {
  description = "Jenkins access URL"
  value       = "http://${aws_instance.jenkins_instance.public_ip}:8080"
}

output "sonarqube_url" {
  description = "SonarQube access URL"
  value       = "http://${aws_instance.jenkins_instance.public_ip}:9000"
}

output "react_app_url" {
  description = "React app access URL"
  value       = "http://${aws_instance.jenkins_instance.public_ip}:3000"
}