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