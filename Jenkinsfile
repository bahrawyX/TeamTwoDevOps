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
        KUBECONFIG_PATH = "${env.WORKSPACE}\\kubeconfig"
    }

    stages {
        stage('Clone Git Repository') {
            steps {
                echo "Cloning the Git repository"
                // Add your git clone command here if needed
            }
        }

        // stage('Build Docker Image') {
        //     steps {
        //         script {
        //             // Build the Docker image with build number as tag
        //             docker.build("${DOCKER_IMAGE}:${env.BUILD_NUMBER}")
        //         }
        //     }
        // }

        stage('Push Docker Image') {
            steps {
                script {
                    echo "Pushing Docker image ${DOCKER_IMAGE}:${env.BUILD_NUMBER} to Docker Hub"
                    withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS}", passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                        bat """
                        echo Logging into Docker Hub...
                        echo %DOCKER_PASSWORD% | docker login -u %DOCKER_USERNAME% --password-stdin
                        docker tag ${DOCKER_IMAGE}:${env.BUILD_NUMBER} ${DOCKER_IMAGE}:latest
                        docker push ${DOCKER_IMAGE}:latest
                        """
                    }
                }
            }
        }

        stage('Terraform Init') {
            steps {
                script {
                    // Initialize Terraform
                    dir("${env.TERRAFORM_CONFIG_PATH}") {
                        bat """${env.TERRAFORM_DIR} init"""
                    }
                }
            }
        }


        stage('Terraform Plan') {
            steps { 
                script {
                    // Generate and show the Terraform execution plan
                    dir("${env.TERRAFORM_CONFIG_PATH}") {
                        bat """${env.TERRAFORM_DIR} plan"""
                    }
                }
            }
        }

        // stage('Terraform Apply') {
        //     steps {
        //         script {
        //             // Apply the Terraform plan to deploy the infrastructure
        //             dir("${env.TERRAFORM_CONFIG_PATH}") {
        //                 bat """${env.TERRAFORM_DIR} apply -auto-approve"""
        //             }
        //         }
        //     }
        // }

        stage('Verify Kubeconfig Path') {
             steps {
                 script {
                     echo "KUBECONFIG path is set to: ${env.KUBECONFIG_PATH}"
                     bat "kubectl config view --kubeconfig ${KUBECONFIG_PATH}"
                 }
             }
         }
         
        stage('Update Kubeconfig') {
    steps {
        script {
            withCredentials([usernamePassword(credentialsId: 'fd08b267-20f1-422b-b2cf-a2f446f18839', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    bat """
                    set AWS_ACCESS_KEY_ID=%AWS_ACCESS_KEY_ID%
                    set AWS_SECRET_ACCESS_KEY=%AWS_SECRET_ACCESS_KEY%
                    set AWS_DEFAULT_REGION= us-east-2
                    
                    aws eks --region %AWS_DEFAULT_REGION% update-kubeconfig --name team2_cluster --kubeconfig C:\\ProgramData\\Jenkins\\.jenkins\\workspace\\TeamTwoFinalProjectPipeLine\\kubeconfig
                    """
            }
        }
    }
}

    stage('Deploy Kubernetes Resources') {
        steps {
            script {
                withCredentials([usernamePassword(credentialsId: 'fd08b267-20f1-422b-b2cf-a2f446f18839', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    bat """
                    set AWS_ACCESS_KEY_ID=%AWS_ACCESS_KEY_ID%
                    set AWS_SECRET_ACCESS_KEY=%AWS_SECRET_ACCESS_KEY%
                    kubectl --kubeconfig ${KUBECONFIG_PATH} apply -f ${env.WORKSPACE}\\k8s\\namespace.yaml
                    kubectl --kubeconfig ${KUBECONFIG_PATH} apply -f ${env.WORKSPACE}\\k8s\\pv.yaml
                    kubectl --kubeconfig ${KUBECONFIG_PATH} apply -f ${env.WORKSPACE}\\k8s\\pvc.yaml
                    kubectl --kubeconfig ${KUBECONFIG_PATH} apply -f ${env.WORKSPACE}\\k8s\\deployment.yaml
                    kubectl --kubeconfig ${KUBECONFIG_PATH} apply -f ${env.WORKSPACE}\\k8s\\service.yaml
                    """
                }
            }
        }
    }


      
         stage('Deploy Ingress') {
            steps {
                sh '--kubeconfig ${KUBECONFIG_PATH} apply -f ${env.WORKSPACE}\\k8s\\ingress.yaml -v-6'
            }
        }

     }



    post {
        always {

             steps { 
                script {
                    echo "Pipeline failed. Destroying the infrastructure..."
                    
                }       
            }
        }
        success {
            echo 'Pipeline completed successfully.'
        }
        failure {
             steps { 
                script {
                    echo "Pipeline failed. Destroying the infrastructure..."
                    
                }       
            }
        }
    }
}
