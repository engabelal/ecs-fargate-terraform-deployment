variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "codedeploy_role_arn" {
  description = "CodeDeploy IAM role ARN"
  type        = string
}

variable "ecs_cluster_name" {
  description = "ECS cluster name"
  type        = string
}

variable "ecs_service_name" {
  description = "ECS service name"
  type        = string
}

variable "listener_arn" {
  description = "ALB listener ARN"
  type        = string
}

variable "blue_target_group_name" {
  description = "Blue target group name"
  type        = string
}

variable "green_target_group_name" {
  description = "Green target group name"
  type        = string
}
