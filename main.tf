# Main configuration file for TeamTwo AWS EKS cluster deployment

provider "aws" {
  region = var.region
}

# Filter out local zones, which are not currently supported 
# with managed node groups
data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  cluster_name = "TeamTwoCluster-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

# Security group for TeamTwo EKS cluster, with enhanced rules
resource "aws_security_group" "teamtwo_sg" {
  name        = "TeamTwo-SG"
  description = "Security Group for TeamTwo Cluster"
  vpc_id      = module.vpc.vpc_id  

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Replace with your specific IP
  }

  # Allow all internal traffic
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]  # Adjust to your VPC CIDR
  }

  tags = {
    Name = "TeamTwo-SG"
  }
}

# Module for VPC setup
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name = "TeamTwoVPC"

  cidr = "10.0.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

# Module for EKS cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.5"

  cluster_name    = local.cluster_name
  cluster_version = "1.29"

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    one = {
      name                 = "TeamTwoNodeGroup1"
      instance_types       = ["t3.micro"]
      min_size             = 1
      max_size             = 3
      desired_size         = 2
      vpc_security_group_ids = [aws_security_group.teamtwo_sg.id]
    }
  }
}

# Application Load Balancer (ALB) setup in the public subnet
resource "aws_lb" "teamtwo_alb" {
  name               = "TeamTwo-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.teamtwo_sg.id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false

  tags = {
    Name = "TeamTwo-ALB"
  }
}

# Target Group for routing traffic to EKS
resource "aws_lb_target_group" "teamtwo_tg" {
  name     = "TeamTwo-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }

  tags = {
    Name = "TeamTwo-TG"
  }
}

# Listener for the ALB
resource "aws_lb_listener" "teamtwo_listener" {
  load_balancer_arn = aws_lb.teamtwo_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.teamtwo_tg.arn
  }
}

# IAM policy for EBS CSI
data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# IAM role for EBS CSI with IRSA
module "irsa-ebs-csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.39.0"

  create_role                   = true
  role_name                     = "TeamTwoAmazonEKSTFEBSCSIRole-${module.eks.cluster_name}"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}
