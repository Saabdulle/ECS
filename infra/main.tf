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

  web_target_group_arn = module.alb.web_target_group_arn
  web_image_tag        = var.web_image_tag

  admin_target_group_arn = module.alb.admin_target_group_arn
  admin_image_tag        = var.admin_image_tag

  space_target_group_arn = module.alb.space_target_group_arn
  space_image_tag        = var.space_image_tag

  api_target_group_arn = module.alb.api_target_group_arn
  # api_image_tag        = var.api_image_tag

  live_target_group_arn = module.alb.live_target_group_arn
  # live_image_tag        = var.live_image_tag
  db_endpoint = module.rds.db_endpoint
  db_port     = module.rds.db_port
  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password

  redis_endpoint = module.redis.redis_endpoint
  redis_port     = module.redis.redis_port

  rabbitmq_host     = module.rabbitmq.rabbitmq_host
  rabbitmq_username = var.rabbitmq_username
  rabbitmq_password = var.rabbitmq_password

  secret_key     = var.secret_key
  s3_bucket_name = module.s3.bucket_name
}

module "rds" {
  source = "./modules/rds"

  project_name          = var.project_name
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  ecs_security_group_id = module.ecs.ecs_security_group_id
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = var.db_password
}

module "redis" {
  source = "./modules/redis"

  project_name          = var.project_name
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  ecs_security_group_id = module.ecs.ecs_security_group_id
}

module "rabbitmq" {
  source = "./modules/rabbitmq"

  project_name              = var.project_name
  aws_region                = var.aws_region
  vpc_id                    = module.vpc.vpc_id
  private_subnet_ids        = module.vpc.private_subnet_ids
  ecs_cluster_id            = module.ecs.cluster_id
  ecs_execution_role_arn    = module.ecs.execution_role_arn
  ecs_task_role_arn         = module.ecs.task_role_arn
  ecs_security_group_id     = module.ecs.ecs_security_group_id
  cloudwatch_log_group_name = module.ecs.cloudwatch_log_group_name
  rabbitmq_username         = var.rabbitmq_username
  rabbitmq_password         = var.rabbitmq_password
}

module "s3" {
  source = "./modules/s3"

  project_name       = var.project_name
  aws_region         = var.aws_region
  ecs_task_role_name = module.ecs.task_role_name
}