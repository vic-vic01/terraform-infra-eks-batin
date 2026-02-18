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