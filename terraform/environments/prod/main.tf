# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  project_name        = var.project_name
  environment         = var.environment
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  availability_zones  = var.availability_zones
}

# Security Module
module "security" {
  source = "../../modules/security"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
}

# DynamoDB Module
module "dynamodb" {
  source = "../../modules/dynamodb"

  table_name  = "urls-${var.environment}"
  environment = var.environment
}

# IAM Module
module "iam" {
  source = "../../modules/iam"

  project_name       = var.project_name
  environment        = var.environment
  dynamodb_table_arn = module.dynamodb.table_arn
}

# ALB Module
module "alb" {
  source = "../../modules/alb"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.vpc.public_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
  certificate_arn       = var.certificate_arn
}

# ECS Module
module "ecs" {
  source = "../../modules/ecs"

  project_name          = var.project_name
  environment           = var.environment
  aws_region            = var.aws_region
  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.vpc.public_subnet_ids
  ecs_security_group_id = module.security.ecs_security_group_id
  execution_role_arn    = module.iam.ecs_task_execution_role_arn
  task_role_arn         = module.iam.ecs_task_role_arn
  target_group_arn      = module.alb.target_group_blue_arn
  container_name        = var.project_name
  container_image       = var.container_image
  container_port        = 8000
  task_cpu              = var.task_cpu
  task_memory           = var.task_memory
  desired_count         = var.desired_count
  dynamodb_table_name   = module.dynamodb.table_name
  base_url              = "https://${var.subdomain}"
  log_retention_days    = 30
}

# CodeDeploy Module
module "codedeploy" {
  source = "../../modules/codedeploy"

  project_name            = var.project_name
  environment             = var.environment
  cluster_name            = module.ecs.cluster_name
  service_name            = module.ecs.service_name
  listener_arn            = module.alb.https_listener_arn
  target_group_blue_name  = module.alb.target_group_blue_name
  target_group_green_name = module.alb.target_group_green_name
  codedeploy_role_arn     = module.iam.codedeploy_role_arn
}

# Route53 Module
module "route53" {
  source = "../../modules/route53"

  domain_name  = var.domain_name
  subdomain    = var.subdomain
  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id  = module.alb.alb_zone_id
}
