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