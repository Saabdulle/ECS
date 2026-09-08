module "ecr" {
  source          = "./modules/ecr"
  repository_name = var.project_name
}

module "vpc" {
  source               = "./modules/vpc"
  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

module "alb" {
  source             = "./modules/alb"
  project_name       = var.project_name
  vpc_id             = module.vpc.vpc_id
  public_subnets_ids = module.vpc.public_subnet_ids
}

