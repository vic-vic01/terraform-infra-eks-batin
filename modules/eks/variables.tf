variable "cluster_name" {
  type        = string
  description = "name of the EKS cluster"
}

variable "subnet_ids" {
  type        = list(string)
  description = "list of subnet IDs for EKS cluster"
}

variable "vpc_id" {
  type        = string
  description = "vpc id where EKS cluster will be created"
}

variable "env" {
  type        = string
  description = "environment name for EKS cluster (dev, staging, prod)"
}

variable "desired_size" {
  type        = number
  description = "desired number of worker nodes"
}

variable "min_size" {
  type        = number
  description = "minimum number of worker nodes"
}

variable "max_size" {
  type        = number
  description = "max number of worker nodes"
}

variable "sso_admin_arn" {
  type        = string
  description = "SSO admin role arn"
}

variable "github_ci_role_arn" {
  type        = string
  description = "GitHub CI role arn"
}

variable "github_tf_role_arn" {
  type        = string
  description = "GitHub Tf role arn"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block for security group rules"
} 

variable "service_cidr" {
  type        = string
  description = "Kubernetes service CIDR block"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version for EKS cluster"
}

variable "ami_owner" {
  type        = string
  description = "AWS account ID that owns the EKS AMI"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for worker nodes"
}

variable "on_demand_base_capacity" {
  type        = number
  description = "minimum number of on-demand instances in ASG"
}

variable "on_demand_percentage" {
  type        = number
  description = "% of on-demand instances in ASG"
} 
