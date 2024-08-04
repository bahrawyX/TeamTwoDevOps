resource "aws_eks_node_group" "team2_node_group" {
  cluster_name    = aws_eks_cluster.team2_cluster.name
  node_group_name = "team2-node-group"
  node_role_arn   = aws_iam_role.team2_node_role.arn
  subnet_ids      = [
    aws_subnet.team2_private_subnet.id,
    aws_subnet.team2_public_subnet.id
  ]
  scaling_config {
    desired_size = var.desired_capacity
    max_size     = 2
    min_size     = 1
  }

  tags = {
    Name = "team2-node-group"
     
  }


}

resource "aws_iam_role" "team2_node_role" {
  name = "team2-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "team2-node-role"
     
  }
}

resource "aws_iam_role_policy_attachment" "team2_node_policy_attachment" {
  role       = aws_iam_role.team2_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_ecr_read_only_policy" {
  role       = aws_iam_role.team2_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "node_eks_cni_policy" {
  role       = aws_iam_role.team2_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ec2_full_access_policy" {
  role       = aws_iam_role.team2_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_security_group" "eks_nodes_sg" {
  vpc_id = aws_vpc.team2_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

#   ingress {
#     from_port   = 5000
#     to_port     = 5000
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "eks-nodes-sg"
     
  }
}
