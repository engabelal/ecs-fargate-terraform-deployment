variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "url-shortener"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}

variable "certificate_arn" {
  description = "ACM certificate ARN"
  type        = string
}

variable "domain_name" {
  description = "Domain name"
  type        = string
}

variable "subdomain" {
  description = "Subdomain"
  type        = string
}

variable "container_image" {
  description = "Container image"
  type        = string
}

variable "task_cpu" {
  description = "Task CPU"
  type        = string
  default     = "256"
}

variable "task_memory" {
  description = "Task memory"
  type        = string
  default     = "512"
}

variable "desired_count" {
  description = "Desired task count"
  type        = number
  default     = 1
}
