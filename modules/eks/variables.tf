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
  default     = 3
}

variable "min_size" {
  type        = number
  description = "minimum number of worker nodes"
  default     = 1
}

variable "max_size" {
  type        = number
  description = "max number of worker nodes"
  default     = 5
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
  description = "VPC CIDR block for security group rules"
  type        = string
} 