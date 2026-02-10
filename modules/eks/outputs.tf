output "cluster_id" {
  description = "id of the EKS cluster"
  value       = aws_eks_cluster.main.id
}
output "cluster_endpoint" {
  description = "endpoint for EKS cluster API server"
  value       = aws_eks_cluster.main.endpoint
}
output "cluster_name" {
  description = "name of the EKS cluster"
  value       = aws_eks_cluster.main.name
}

output "node_security_group_id" {
  description = "Security group ID for worker nodes"
  value       = aws_security_group.eks_nodes.id
}

output "asg_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.eks_nodes.name
}