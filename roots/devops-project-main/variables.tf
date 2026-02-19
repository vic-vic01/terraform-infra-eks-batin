variable "greeting" {
  description = "A greeting phrase"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
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

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version for EKS cluster"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for worker nodes"
}

variable "on_demand_percentage" {
  type        = number
  description = "% of on-demand instances in ASG"
}

variable "on_demand_base_capacity" {
  type        = number
  description = "base number of on-demand instances in ASG"
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

variable "ami_owner" {
  type        = string
  description = "AWS account ID that owns the EKS AMI"
}

variable "service_cidr" {
  type        = string
  description = "Kubernetes service CIDR block"
}