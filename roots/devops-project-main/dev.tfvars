greeting = "Hi"

vpc_cidr     = "10.0.0.0/16"
environment  = "dev"
project_name = "eks-cluster"

availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

cluster_name = "eks-dev-cluster"

kubernetes_version      = "1.34"
instance_type           = "t3.medium"
on_demand_percentage    = 20
on_demand_base_capacity = 0

desired_size = 3
min_size     = 1
max_size     = 5
ami_owner    = "602401143452"
service_cidr = "172.20.0.0/16"