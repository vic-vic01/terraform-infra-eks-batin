resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.29"

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]
}

resource "aws_iam_role" "eks_node_role" {
  name = "${var.cluster_name}-node-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEBSCSIDriverPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.eks_node_role.name
} 

resource "aws_iam_instance_profile" "eks_node_instance_profile" {
  name = "${var.cluster_name}-node-instance-profile"
  role = aws_iam_role.eks_node_role.name
}

resource "aws_security_group" "eks_nodes" {
  name        = "${var.cluster_name}-node-sg"
  description = "security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow nodes to communicate with each other"
    from_port   = 0
    to_port     = 65535
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-node-sg"
  }
}

data "aws_ami" "eks_ami" {
  most_recent = true
  owners      = ["602401143452"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-1.29-*"]
  }
}

resource "aws_launch_template" "eks_nodes" {
  name          = "${var.cluster_name}-node-template"
  image_id      = data.aws_ami.eks_ami.id
  instance_type = "t3.medium"

  iam_instance_profile {
    arn = aws_iam_instance_profile.eks_node_instance_profile.arn
  }

  vpc_security_group_ids = [aws_security_group.eks_nodes.id]

  user_data = base64encode("#!/bin/bash\n/etc/eks/bootstrap.sh ${var.cluster_name}")
}

resource "aws_autoscaling_group" "eks_nodes" {
  name                = "${var.cluster_name}-node-asg"
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_size
  vpc_zone_identifier = var.subnet_ids

  depends_on = [aws_eks_cluster.main]

  mixed_instances_policy {                    
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.eks_nodes.id
        version            = "$Latest"
      }
    }

    instances_distribution {                  
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 20
      spot_allocation_strategy                 = "lowest-price"
    }
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }
}

resource "aws_eks_access_entry" "sso_admin" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = var.sso_admin_arn
}

resource "aws_eks_access_entry" "github_ci" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = var.github_ci_role_arn
}

resource "aws_eks_access_entry" "github_terraform" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = var.github_tf_role_arn
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
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
  
  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.github_ci]
}

resource "aws_eks_access_policy_association" "github_terraform_policy" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = var.github_tf_role_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
  
  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.github_terraform]
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "vpc-cni"

  depends_on = [aws_autoscaling_group.eks_nodes]
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "aws-ebs-csi-driver"

  depends_on = [aws_autoscaling_group.eks_nodes]
}