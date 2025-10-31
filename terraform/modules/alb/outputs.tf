output "alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "ALB zone ID"
  value       = aws_lb.main.zone_id
}

output "target_group_blue_arn" {
  description = "Blue target group ARN"
  value       = aws_lb_target_group.blue.arn
}

output "target_group_green_arn" {
  description = "Green target group ARN"
  value       = aws_lb_target_group.green.arn
}

output "target_group_blue_name" {
  description = "Blue target group name"
  value       = aws_lb_target_group.blue.name
}

output "target_group_green_name" {
  description = "Green target group name"
  value       = aws_lb_target_group.green.name
}

output "https_listener_arn" {
  description = "HTTPS listener ARN"
  value       = aws_lb_listener.https.arn
}
