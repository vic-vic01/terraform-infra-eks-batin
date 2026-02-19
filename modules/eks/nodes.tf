data "aws_ami" "eks_ami" {
  most_recent = true
  owners      = [var.ami_owner]

  filter {
    name   = "name"
    values = ["amazon-eks-node-al2023-x86_64-standard-${var.kubernetes_version}-*"]
  }
}

resource "aws_security_group" "eks_nodes" {
  name        = "${var.cluster_name}-node-sg"
  description = "security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  ingress {
    description = "allow nodes to communicate with each other"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  ingress {
    description = "allow cluster control plane communication"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description = "allow kubelet API"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-node-sg"
  }
}

resource "aws_launch_template" "eks_nodes" {
  name          = "${var.cluster_name}-node-template"
  image_id      = data.aws_ami.eks_ami.id
  instance_type = var.instance_type

  iam_instance_profile {
    arn = aws_iam_instance_profile.eks_node_instance_profile.arn
  }

  vpc_security_group_ids = [aws_security_group.eks_nodes.id]

  user_data = base64encode(<<-EOF
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="BOUNDARY"

--BOUNDARY
Content-Type: application/node.eks.aws

---
apiVersion: node.eks.aws/v1alpha1
kind: NodeConfig
spec:
  cluster:
    name: ${aws_eks_cluster.main.name}
    apiServerEndpoint: ${aws_eks_cluster.main.endpoint}
    certificateAuthority: ${aws_eks_cluster.main.certificate_authority[0].data}
    cidr: ${var.service_cidr}
--BOUNDARY--
EOF
)
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

      override {
        instance_type = "t3.medium"
      }
      override {
        instance_type = "t3.large"
      }
      override {
        instance_type = "m5.large"
      }
      override {
        instance_type = "m5a.large"
      }
      override {
        instance_type = "m4.large"
      }
    }

    instances_distribution {
      on_demand_base_capacity                  = var.on_demand_base_capacity
      on_demand_percentage_above_base_capacity = var.on_demand_percentage
      spot_allocation_strategy                 = "capacity-optimized"
    }
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }
}