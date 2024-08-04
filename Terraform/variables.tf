variable "region" {
  description = "The AWS region to deploy resources"
  default     = "us-east-2"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "The CIDR block for the public subnet"
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "The CIDR block for the private subnet"
  default     = "10.0.2.0/24"
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  default     = "team2_test-cluster"
}

variable "node_instance_type" {
  description = "The EC2 instance type for the worker nodes"
  default     = "t3.micro"
}

variable "desired_capacity" {
  description = "The desired number of worker nodes"
  default     = 1
}
