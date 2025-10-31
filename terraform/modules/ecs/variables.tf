variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for ECS tasks"
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "ECS security group ID"
  type        = string
}

variable "execution_role_arn" {
  description = "ECS task execution role ARN"
  type        = string
}

variable "task_role_arn" {
  description = "ECS task role ARN"
  type        = string
}

variable "target_group_arn" {
  description = "Target group ARN"
  type        = string
}

variable "container_name" {
  description = "Container name"
  type        = string
}

variable "container_image" {
  description = "Container image"
  type        = string
}

variable "container_port" {
  description = "Container port"
  type        = number
  default     = 8000
}

variable "task_cpu" {
  description = "Task CPU units"
  type        = string
}

variable "task_memory" {
  description = "Task memory (MB)"
  type        = string
}

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name"
  type        = string
}

variable "base_url" {
  description = "Base URL for shortened links"
  type        = string
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}
