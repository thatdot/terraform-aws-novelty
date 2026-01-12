# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

output "url" {
  description = "URL to access Novelty web interface"
  value       = var.domain_name != null ? "https://${var.domain_name}" : module.novelty.alb_url
}

output "certificate_arn" {
  description = "ARN of the ACM certificate (created or provided)"
  value       = local.certificate_arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.novelty.alb_dns_name
}

output "alb_zone_id" {
  description = "Route53 zone ID for ALB (for DNS alias records)"
  value       = module.novelty.alb_zone_id
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.novelty.ecs_cluster_name
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = module.novelty.ecs_cluster_arn
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = module.novelty.ecs_service_name
}

output "ecs_task_definition_arn" {
  description = "ARN of the ECS task definition"
  value       = module.novelty.ecs_task_definition_arn
}

output "cloudwatch_log_group" {
  description = "CloudWatch log group for container logs"
  value       = module.novelty.cloudwatch_log_group_name
}

output "task_execution_role_arn" {
  description = "ARN of the task execution IAM role"
  value       = module.novelty.ecs_task_execution_role_arn
}

output "task_role_arn" {
  description = "ARN of the task IAM role"
  value       = module.novelty.ecs_task_role_arn
}

output "alb_security_group_id" {
  description = "Security group ID for the ALB"
  value       = module.novelty.alb_security_group_id
}

output "ecs_security_group_id" {
  description = "Security group ID for ECS tasks"
  value       = module.novelty.ecs_tasks_security_group_id
}

output "vpc_id" {
  description = "VPC ID where resources are deployed"
  value       = module.novelty.vpc_id
}

output "subnet_ids" {
  description = "Subnet IDs where resources are deployed"
  value       = module.novelty.subnet_ids
}
