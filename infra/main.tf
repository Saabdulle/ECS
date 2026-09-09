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
  certificate_arn    = module.acm.certificate_arn
}

module "acm" {
  source       = "./modules/acm"
  project_name = var.project_name
  domain_name  = var.domain_name
}

module "ecs" {
  source = "./modules/ecs"

  project_name = var.project_name
  aws_region   = var.aws_region

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  alb_security_group_id = module.alb.alb_security_group_id

  ecr_repository_url = module.ecr.repository_url

  web_target_group_arn   = module.alb.web_target_group_arn
  admin_target_group_arn = module.alb.admin_target_group_arn
  space_target_group_arn = module.alb.space_target_group_arn
  api_target_group_arn   = module.alb.api_target_group_arn
  live_target_group_arn  = module.alb.live_target_group_arn
}