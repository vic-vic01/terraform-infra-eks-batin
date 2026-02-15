# Production - not using during project, only dev

greeting             = "Hi"
vpc_cidr             = "10.2.0.0/16"
environment          = "prod"
project_name         = "eks-cluster"
availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]
public_subnet_cidrs  = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
private_subnet_cidrs = ["10.2.11.0/24", "10.2.12.0/24", "10.2.13.0/24"]
cluster_name         = "eks-prod-cluster"