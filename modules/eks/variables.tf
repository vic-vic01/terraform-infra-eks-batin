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