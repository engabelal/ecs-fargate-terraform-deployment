output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.alb.alb_dns_name
}

output "application_url" {
  description = "Application URL"
  value       = "https://${var.subdomain}"
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.cluster_name
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = module.dynamodb.table_name
}

output "codedeploy_app_name" {
  description = "CodeDeploy application name"
  value       = module.codedeploy.app_name
}
