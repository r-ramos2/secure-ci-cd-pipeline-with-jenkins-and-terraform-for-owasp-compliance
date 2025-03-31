# Secure CI/CD Pipeline with Jenkins and Terraform for OWASP Compliance

## Table of Contents

- [Introduction](#introduction)
- [Project Overview](#project-overview)
- [Architecure Diagram](#architecture-diagram)
- [Security Best Practices](#security-best-practices)
- [Prerequisites](#prerequisites)
- [Project Setup and Execution](#project-setup-and-execution)
- [Jenkins Setup and Configuration](#jenkins-setup-and-configuration)
- [SonarQube Setup](#sonarqube-setup)
- [React Application Setup](#react-application-setup)
- [Pipeline Configuration](#pipeline-configuration)
- [Conclusion](#conclusion)
- [Resources](#resources)

## Introduction

This comprehensive guide demonstrates how to deploy a secure and scalable AWS DevSecOps project utilizing Jenkins, SonarQube, and a React application. The goal is to implement Infrastructure as Code (IaC) practices using Terraform while adhering to AWS best security practices as of November 2024. This guide will help you deploy your applications and services on AWS EC2 instances, following security protocols and configurations that make the system production-ready.

## Project Overview

This project includes deploying:

- **Jenkins**: CI/CD automation server.
- **SonarQube**: Code quality and security inspection platform.
- **React**: A frontend application deployed for demonstration.

All services run on a single `t2.medium` EC2 instance to consolidate costs while maintaining sufficient resources.

## Architecture Diagram

<img width="595" alt="architecture-1" src="https://github.com/user-attachments/assets/2af63789-5262-487f-b00e-e9bc59d4ee1f" />

*Architecutre diagram*

### Cost Considerations
The `t2.medium` instance, costing approximately $0.0464 per hour in `us-east-1`, provides:

- 2 vCPUs and 4GB memory for multi-service operations.

This design avoids additional costs by:

- Deploying in a single availability zone (single-AZ).
- Limiting storage to a 30GB gp3 volume.

## Security Best Practices

### IAM and Role-Based Access Control
- Use an IAM user with restricted access (no admin permissions).
- Assign an EC2 role with the least privileges necessary.

### Terraform Best Practices
- Validate configurations before applying (`terraform validate`).
- Destroy unused resources with `terraform destroy` after use.

### Network Security
- Restrict security groups to allow only specific IPs on required ports (e.g., 22, 8080, 9000, 3000).

### Dependency Scanning
- Integrate OWASP and Trivy stages in Jenkins for vulnerability management.

## Prerequisites

- AWS Account with CLI configured.
- Terraform installed locally.
- SSH Key Pair for EC2 instance access.
- GitHub Repository with the React application source code.

## Project Setup and Execution

1. Clone the repository:
    ```bash
    git clone https://github.com/r-ramos2/aws-devsecops-react-app.git
    cd aws-devsecops-react-app
    ```
2. Initialize and apply Terraform:
    ```bash
    terraform init
    terraform validate
    terraform plan
    terraform apply
    ```
3. Note the public IP of the EC2 instance from Terraform outputs.

## Jenkins Setup and Configuration

1. Access Jenkins:
    - Visit `http://<public_ip>:8080`.

2. Retrieve the Admin Password:
    ```bash
    sudo cat /var/lib/jenkins/secrets/initialAdminPassword
    ```
    - Use this password for the initial login and update it immediately.

3. Install Required Plugins:
    - Eclipse Temurin, SonarQube Scanner, NodeJS, OWASP, Docker.

4. Add Global Tools:
    - **JDK 17**: Install from adoptium.net (version 17.0.8.1).
    - **SonarQube Scanner**: Install version 5.0.1.3006.
    - **NodeJS**: Install version 16.2.0.
    - **Dependency-Check**: Install version 6.5.1.

## SonarQube Setup

1. Access SonarQube:
    - Visit `http://<public_ip>:9000`.

2. Generate an Authentication Token:
    - Navigate to Security > Tokens and create a token named "Jenkins".

3. Integrate with Jenkins:
    - Add the token under Manage Jenkins > Credentials as `sonar-token`.
    - Configure SonarQube server settings in Jenkins:
        - Name: `sonar-server`
        - URL: `http://<public_ip>:9000`
        - Token: `sonar-token`

## React Application Setup

1. SSH into the Instance:
    ```bash
    ssh -i your_key.pem ec2-user@<public_ip>
    ```

2. Run the Application:
    ```bash
    npm install
    npm run build
    npm start
    ```
    - Access the app at `http://<public_ip>:3000`.

## Pipeline Configuration

1. Create a Jenkins Pipeline:
    - Navigate to New Item > Pipeline.
    - Paste the Jenkinsfile contents into the pipeline script section.
    
2. Run the Pipeline:
    - Check the results in Jenkins and SonarQube.

## Conclusion

This project deploys a secure, scalable AWS DevSecOps environment for Jenkins, SonarQube, and React using Terraform. By following the security best practices outlined, you ensure that your cloud infrastructure is both effective and safe. This setup offers a robust foundation for building, testing, and deploying applications securely within AWS.

## Resources

- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [Terraform Documentation](https://www.terraform.io/docs/index.html)
- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [SonarQube Documentation](https://docs.sonarqube.org/latest/)
