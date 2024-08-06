# DevOps Final Project

## Project Overview

This Project is designed to comprehensively integrate various aspects of DevOps practices. This project provides a practical, hands-on experience by combining application development, Dockerization, Kubernetes deployment, CI/CD automation, and infrastructure management using Terraform.

The project is divided into the following parts:

1. **Part 1: Application Development**
2. **Part 2: Dockerization**
3. **Part 3: Infrastructure as Code with Terraform**
4. **Part 4: Kubernetes Deployment on EKS**
5. **Part 5: CI/CD Pipeline Setup**


<br>


## Part 1: Application Development

### Overview
This project segment involves developing a library management web application using Flask in Python. The application offers essential features for managing book inventory and user interactions.

### Key Features
- **Book Management**: Add, remove, and search for books.
- **User Actions**: Borrow and return books.
- **Data Storage**: Uses a JSON file to store book information.

### Implementation Details
- **Data Management**:
  - Load and save book data from/to a JSON file.
- **User Interaction**:
  - Display lists of available and borrowed books.
  - Handle form submissions for adding, removing, searching, borrowing, and returning books.

### HTML Template
- **index.html**: Utilizes Bootstrap for layout and styling, with Jinja2 for rendering dynamic content.



<br>


## Part 2: Dockerization

### Description
In this phase, the library management application was containerized using Docker to facilitate consistent deployment and environment management.

### Implementation
- **Dockerfile Creation**: A `Dockerfile` was crafted to define the application’s environment, including the installation of dependencies and configuration of runtime settings.
- **Image Building and Testing**: The Docker image was built and tested locally to ensure that the containerized application operates correctly and meets the expected performance standards.
- **Deployment Preparation**: The Docker image was then pushed to Docker Hub, making it readily accessible for deployment in various environments.

This process ensures that the application is encapsulated in a portable container, which simplifies deployment across different systems and environments.



<br>

## Part 3: Infrastructure as a Code with Terraform

### Description
This phase involved the use of Terraform to provision and manage the AWS infrastructure necessary for deploying the application. Five Terraform configuration files were created to define and deploy the resources required for the AWS EKS cluster and its associated components.

### Files and Their Purposes

- **vpc.tf**:
  - Defines the Virtual Private Cloud (VPC), subnets, and related networking resources.
  - Configures an internet gateway, NAT gateway, and route tables to ensure proper routing of network traffic.

- **cluster.tf**:
  - Contains the configuration for the Amazon EKS cluster, including its creation.
  - Defines the necessary IAM roles required for the EKS cluster.

- **nodes.tf**:
  - Configures the EKS node group and the associated IAM roles and policies.
  - Specifies the security group for the EKS nodes, detailing inbound and outbound traffic rules.

- **outputs.tf**:
  - Specifies the outputs from the Terraform configuration.
  - Includes details such as the EKS cluster name, endpoint, and node group role ARN.

- **variables.tf**:
  - Defines variables used across the Terraform configurations.
  - Includes settings for region, CIDR blocks for networking, and cluster-specific configurations.
    

<br>


## Part 4: Kubernetes Deployment on EKS

### Description
Deploy a Dockerized application to an AWS EKS cluster using Kubernetes configuration files.

### Kubernetes Configuration Files

- **Deployment YAML**: Configures the application deployment with replica count, container image, and volume mounts.
- **Ingress YAML**: Manages external access with routing rules and TLS configuration.
- **Namespace YAML**: Creates a namespace for organizing application resources.
- **Persistent Volume YAML**: Defines a storage volume with specified capacity and access modes.
- **Persistent Volume Claim YAML**: Requests storage from the PersistentVolume with defined size and access modes.
- **Service YAML**: Exposes the application using a LoadBalancer, including port mappings and selectors.



<br>

## Part 5: CI/CD Pipeline Setup

### Description
Jenkins was used to automate the deployment process of the application, ensuring a streamlined and repeatable workflow. It manages tasks from code retrieval to infrastructure deployment, integrating with Docker and Kubernetes to automate builds and updates.

### Pipeline Stages

- **Clone Git Repository**: Retrieves the latest application code.
- **Build Docker Image**: Creates and tags the Docker image for deployment.
- **Push Docker Image to Docker Hub**: Uploads the Docker image to Docker Hub for access.
- **Terraform Init**: Prepares Terraform for deployment.
- **Terraform Plan**: Generates a plan for the infrastructure changes.
- **Terraform Apply**: Applies the Terraform plan to set up the infrastructure.
- **Verify Kubeconfig Path**: Checks the Kubernetes configuration path.
- **Update Kubeconfig**: Updates the Kubeconfig with AWS credentials.
- **Deploy Kubernetes Resources**: Deploys resources like namespace, PV, PVC, deployment, and service to the EKS cluster.


<br>


## Bonus Task: Set Up Monitoring and Logging

### Objective
Implement monitoring and logging to ensure the application's health and performance.

### Contributions

- **Prometheus**: Deployed on EKS to collect and monitor metrics from the application.
- **Grafana**: Deployed on EKS to visualize metrics collected by Prometheus.
- **Grafana Dashboards**: Created to monitor cluster resource usage and application-specific metrics.
- **Prometheus Alerts**: Configured to notify on conditions like high CPU usage and increased response times.

This setup provides real-time insights and alerts, enabling proactive issue detection and system performance improvements.
