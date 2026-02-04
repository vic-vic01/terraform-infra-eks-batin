variable "vpc_cidr" {
  type        = string
  description = "main cidr block for vpc"
}

variable "env" {
  type        = string
  description = "environment name"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "addresses for public subnets"
}

variable "azs" {
  type        = list(string)
  description = "availability zones"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "cidr blocks for private subnets"
}

variable "cluster_name" {
  type        = string
  description = "name of eks cluster"
}