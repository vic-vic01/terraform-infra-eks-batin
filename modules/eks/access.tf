resource "aws_eks_access_entry" "sso_admin" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = var.sso_admin_arn
}

resource "aws_eks_access_entry" "github_ci" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = var.github_ci_role_arn
}

resource "aws_eks_access_entry" "nodes" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = aws_iam_role.eks_node_role.arn
  type          = "EC2_LINUX"

  depends_on = [aws_eks_cluster.main]
}

resource "aws_eks_access_policy_association" "sso_admin_policy" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = var.sso_admin_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.sso_admin]
}

resource "aws_eks_access_policy_association" "github_ci_policy" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = var.github_ci_role_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.github_ci]
}