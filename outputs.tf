output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "alb_dns_name" {
  description = "ALB DNS Name"
  value       = module.alb.alb_dns_name
}

output "db_endpoint" {
  description = "RDS Endpoint"
  value       = module.database.db_endpoint
}

output "ecr_repository_url" {
  description = "ECR Repository URL"
  value       = module.compute.ecr_repository_url
}

output "ecs_cluster_name" {
  description = "ECS Cluster Name"
  value       = module.compute.ecs_cluster_name
}
