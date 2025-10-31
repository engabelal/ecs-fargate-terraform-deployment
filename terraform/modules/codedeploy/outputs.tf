output "app_name" {
  description = "CodeDeploy application name"
  value       = aws_codedeploy_app.main.name
}

output "deployment_group_name" {
  description = "CodeDeploy deployment group name"
  value       = aws_codedeploy_deployment_group.main.deployment_group_name
}
