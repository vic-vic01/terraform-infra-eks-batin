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