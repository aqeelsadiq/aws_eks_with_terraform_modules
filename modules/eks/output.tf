output "cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}
output "cluster_arn" {
  value = aws_eks_cluster.eks_cluster.arn
}

output "cluster_name" {
  value = aws_eks_cluster.eks_cluster.name

}

output "eks_node_role_arn" {
  value = aws_eks_node_group.eks_node_group.arn
}

output "aws_security_group_id" {
  value = aws_security_group.eks_node_sg.id
}
