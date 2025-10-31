variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "cluster_name" {
  description = "ECS cluster name"
  type        = string
}

variable "service_name" {
  description = "ECS service name"
  type        = string
}

variable "listener_arn" {
  description = "ALB listener ARN"
  type        = string
}

variable "target_group_blue_name" {
  description = "Blue target group name"
  type        = string
}

variable "target_group_green_name" {
  description = "Green target group name"
  type        = string
}

variable "codedeploy_role_arn" {
  description = "CodeDeploy IAM role ARN"
  type        = string
}
