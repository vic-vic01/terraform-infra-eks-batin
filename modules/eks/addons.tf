resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "vpc-cni"

  timeouts {
    create = "30m"
    update = "30m"
    delete = "15m"
  }

  depends_on = [aws_autoscaling_group.eks_nodes]
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "aws-ebs-csi-driver"

  timeouts {
    create = "30m"
    update = "30m"
    delete = "15m"
  }

  depends_on = [aws_autoscaling_group.eks_nodes]
}