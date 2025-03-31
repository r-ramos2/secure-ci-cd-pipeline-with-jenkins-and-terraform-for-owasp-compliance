pipeline {
    agent any
    tools {
        jdk 'jdk17'           // Ensure JDK 17 is available (configure under Jenkins > Global Tool Configuration)
        nodejs 'node16'        // Ensure Node.js 16 is available (configure under Jenkins > Global Tool Configuration)
    }
    environment {
        SCANNER_HOME = tool 'sonar-scanner'  // Ensure SonarQube scanner is available (configured under Jenkins > Global Tool Configuration)
    }
    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs() // Clean the workspace before starting the build
            }
        }
        stage('Git Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/r-ramos2/secure-ci-cd-pipeline-with-jenkins-and-terraform-for-owasp-compliance.git'  // Your Git repo URL
            }
        }
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv(credentialsId: 'sonar-server') {
                    // Running the SonarQube scan using the scanner tool
                    sh '''
                    $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Amazon \
                    -Dsonar.projectKey=Amazon
                    '''
                }
            }
        }
        stage('Quality Gate') {
            steps {
                script {
                    // Wait for SonarQube Quality Gate to pass before proceeding
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        stage('Install Dependencies') {
            steps {
                // Install dependencies using npm (assuming package.json exists in the root)
                sh 'npm install'
            }
        }
        stage('OWASP Dependency Check') {
            steps {
                // Run OWASP Dependency Check on the project
                dependencyCheck additionalArguments: '--scan / --disableYarnAudit --disableNodeAudit', odcInstallation: 'DP-Check'
                // Publish Dependency Check report
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        stage('Trivy File Scan') {
            steps {
                // Run Trivy filesystem scan on the project
                sh 'trivy fs . > TRIVYFS.txt'
            }
        }
        stage('Docker Build and Push') {
            steps {
                script {
                    // Build Docker image, tag it, and push it to Docker Hub
                    sh '''
                    docker build -t amazon .
                    docker tag amazon your_docker_username/amazon:latest
                    docker push your_docker_username/amazon:latest
                    '''
                }
            }
        }
        stage('Trivy Image Scan') {
            steps {
                // Run Trivy scan on the Docker image
                sh 'trivy image your_docker_username/amazon:latest > TRIVYIMAGE.txt'
            }
        }
        stage('Run Amazon App') {
            steps {
                // Run the Docker container for your app
                sh 'docker run -d --name amazon -p 3000:3000 your_docker_username/amazon:latest'
            }
        }
    }
    post {
        always {
            // Cleanup actions after the pipeline finishes, such as cleaning up Docker containers
            sh 'docker rm -f amazon || true'
        }
    }
}
