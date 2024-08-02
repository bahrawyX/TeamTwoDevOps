pipeline {
    agent any

    environment {
        DOCKER_IMAGE = ""
        DOCKER_REGISTRY = "your-docker-registry-url"
        GIT_REPO = "https://github.com/your-github-username/your-repo.git"
        TERRAFORM_DIR = "terraform-directory"
    }

    stages {
        stage('Checkout') {
            steps {
                // Clone the Git repository
                git branch: 'main', url: "${GIT_REPO}"
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image
                    docker.build("${DOCKER_IMAGE}")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    // Login to Docker registry
                    withCredentials([usernamePassword(credentialsId: 'docker-credentials-id', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh "echo ${DOCKER_PASS} | docker login ${DOCKER_REGISTRY} -u ${DOCKER_USER} --password-stdin"
                    }
                    // Push the Docker image to the registry
                    docker.image("${DOCKER_IMAGE}").push('latest')
                }
            }
        }

        stage('Terraform Init') {
            steps {
                dir("${TERRAFORM_DIR}") {
                    script {
                        // Initialize Terraform
                        sh 'terraform init'
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir("${TERRAFORM_DIR}") {
                    script {
                        // Generate and show the Terraform execution plan
                        sh 'terraform plan'
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir("${TERRAFORM_DIR}") {
                    script {
                        // Apply the Terraform plan to deploy the infrastructure
                        sh 'terraform apply -auto-approve'
                    }
                }
            }
        }
    }

    post {
        always {
            // Clean up workspace after build
            cleanWs()
        }
        success {
            echo 'Pipeline completed successfully.'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}
