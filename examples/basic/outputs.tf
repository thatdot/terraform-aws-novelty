# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

output "url" {
  description = "URL to access Novelty web interface"
  value       = module.novelty.alb_url
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.novelty.alb_dns_name
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.novelty.ecs_cluster_name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = module.novelty.ecs_service_name
}

output "cloudwatch_log_group" {
  description = "CloudWatch log group for viewing container logs"
  value       = module.novelty.cloudwatch_log_group_name
}
