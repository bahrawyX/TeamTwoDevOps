pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "xbahrawy/finalproject"
        TERRAFORM_DIR = "${terraform}"
        AWS_DIR = "${aws}"
        KUBECTL_DIR = "${kubectl}"
        DOCKER_CREDENTIALS = '135feaae-4bb5-4233-8869-4cf8939df9ed'
        AWS_CREDENTIALS = 'fd08b267-20f1-422b-b2cf-a2f446f18839'
        TERRAFORM_CONFIG_PATH = "${env.WORKSPACE}\\terraform"    
    }


    stages {
        stage('Clonning Git Repository') {
            steps {
                echo" Clonning the Git repository"
            }
        }

       stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image with build number as tag
                    docker.build("${DOCKER_IMAGE}:${env.BUILD_NUMBER}")
                }
            }
        }
        
       
   
        stage('Push Docker Image') {
            steps {
                script {
                    echo "Pushing Docker image ${DOCKER_IMAGE}:${env.BUILD_NUMBER} to Docker Hub"
                    withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS}", passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                        bat """
                        echo Logging into Docker Hub...
                        echo %DOCKER_PASSWORD% | docker login -u %DOCKER_USERNAME% --password-stdin
                        docker tag ${DOCKER_IMAGE}:${env.BUILD_NUMBER} ${DOCKER_IMAGE}:latest
                        docker push ${DOCKER_IMAGE}:${env.BUILD_NUMBER}
                        docker push ${DOCKER_IMAGE}:latest
                        """
                    }
                }
            }
        }

        stage('Terraform Init') {
            steps {
                dir("${TERRAFORM_DIR}") {
                    script {
                        // Initialize Terraform
                        dir("${env.TERRAFORM_CONFIG_PATH}") {
                        bat""""${env.TERRAFORM_DIR}" init"""

                     }
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir("${TERRAFORM_DIR}") {
                    script {
                        // Generate and show the Terraform execution plan
                        dir("${env.TERRAFORM_CONFIG_PATH}") {
                            bat""""${env.TERRAFORM_DIR}" plan"""

                        }
                        
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir("${TERRAFORM_DIR}") {
                    script {
                        // Apply the Terraform plan to deploy the infrastructure
                        bat """"${env.TERRAFORM_DIR}" apply -auto-approve"""
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
