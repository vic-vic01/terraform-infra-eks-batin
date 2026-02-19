# DO NOT REMOVE DUMMY MODULE references and their code, they should remain as examples
module "module1" {
  source = "../../dummy-module-1"
  # ... any required variables for module1
  greeting = var.greeting

}

module "module2" {
  source = "../../dummy-module-2"

  input_from_module1 = module.module1.greeting_message
  # ... any other required variables for module2
}


module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr             = var.vpc_cidr
  env                  = var.environment
  public_subnet_cidrs  = var.public_subnet_cidrs
  azs                  = var.availability_zones
  private_subnet_cidrs = var.private_subnet_cidrs
  cluster_name         = var.cluster_name
}

module "eks" {
  source = "../../modules/eks"

  cluster_name            = var.cluster_name
  vpc_id                  = module.vpc.vpc_id
  subnet_ids              = module.vpc.public_subnet_ids
  vpc_cidr                = module.vpc.vpc_cidr
  env                     = var.environment
  sso_admin_arn           = var.sso_admin_arn
  github_ci_role_arn      = var.github_ci_role_arn
  github_tf_role_arn      = var.github_tf_role_arn
  kubernetes_version      = var.kubernetes_version
  instance_type           = var.instance_type
  on_demand_percentage    = var.on_demand_percentage
  on_demand_base_capacity = var.on_demand_base_capacity
  desired_size            = var.desired_size
  min_size                = var.min_size
  max_size                = var.max_size
  ami_owner               = var.ami_owner
  service_cidr            = var.service_cidr
}
