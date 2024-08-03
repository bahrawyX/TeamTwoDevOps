provider "aws" {
  region = var.region
}

# Filter out local zones, which are not currently supported with managed node groups
data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

locals {
  cluster_name = "TeamTwoCluster-${random_string.suffix.result}"
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
  cluster_endpoint_private_access           = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  
  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64",
    iam_role_use_name_prefix = false
  }

  eks_managed_node_groups = {
    one = {
      name                 = "TTNodeGroup1"
      instance_types       = ["t3.micro"]
      min_size             = 1
      max_size             = 3
      desired_size         = 2
      vpc_security_group_ids = [aws_security_group.teamtwo_sg.id]
      iam_role_name        = "TTNodeGroupRole"  # Explicitly set a shorter role name
    }
}
}
# module "eks" {
#   source  = "terraform-aws-modules/eks/aws"
#   version = "20.8.5"

#   cluster_name    = local.cluster_name
#   cluster_version = "1.29"

#   cluster_endpoint_public_access           = true
#   cluster_endpoint_public_access_cidrs     = ["203.0.113.0/24", "198.51.100.0/24"]  // Specify allowed CIDR blocks
#   cluster_endpoint_private_access          = true

#   vpc_id     = module.vpc.vpc_id
#   subnet_ids = module.vpc.private_subnets

#   eks_managed_node_group_defaults = {
#     ami_type = "AL2_x86_64"
#   }

#   eks_managed_node_groups = {
#     one = {
#       name                 = "TeamTwoNodeGroup1"
#       instance_types       = ["t3.micro"]
#       min_size             = 1
#       max_size             = 3
#       desired_size         = 2
#       vpc_security_group_ids = [aws_security_group.teamtwo_sg.id]
#     }
#   }
# }


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

# Target Group for routing traffic to EKS  AKA LOAD BALANCER
# Listener for the ALB
resource "aws_lb_target_group" "teamtwo_tg" {
  name     = "TeamTwo-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    enabled             = true
    interval            = 30
    path                = "/health"  // Change this to a specific health check endpoint if available
    protocol            = "HTTP"
    healthy_threshold   = 2         // Adjust based on tolerance for intermittent failures
    unhealthy_threshold = 2          // Adjust based on tolerance for recovery time
    timeout             = 10         // Consider increasing timeout if the service takes longer to respond
    matcher             = "200"      // Ensure the endpoint returns HTTP 200 for health
  }

  tags = {
    Name = "TeamTwo-TG"
  }
}
# IAM Role for EKS Cluster Access
resource "aws_iam_role" "eks_access_role" {
  name = "TeamTwoEksAccessRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "TeamTwoEksAccessRole"
  }
}



#IAM policy for EKS cluster
resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
  role       = aws_iam_role.eks_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_service_policy_attachment" {
  role       = aws_iam_role.eks_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller" {
  role       = aws_iam_role.eks_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

resource "aws_iam_role_policy_attachment" "eks_admin_access" {
  role       = aws_iam_role.eks_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}


#worker node role
resource "aws_iam_role" "eks_worker_role" {
  name = "TeamTwoEksWorkerRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "TeamTwoEksWorkerRole"
  }
}

#worker node policies
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  role       = aws_iam_role.eks_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "ec2_full_access" {
  role       = aws_iam_role.eks_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "worker_admin_access" {
  role       = aws_iam_role.eks_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

