output "cluster_name" {
  value = aws_eks_cluster.team2_cluster.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.team2_cluster.endpoint
}

output "cluster_certificate_authority_data" {
  value = aws_eks_cluster.team2_cluster.certificate_authority[0].data
}

output "node_group_role_arn" {
  value = aws_iam_role.team2_node_role.arn
}
