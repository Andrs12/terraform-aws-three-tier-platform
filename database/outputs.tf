output "cluster_endpoint" {
  description = "The writer endpoint for the Aurora cluster."
  value       = aws_rds_cluster.database.endpoint
}

output "reader_endpoint" {
  description = "The reader endpoint for the Aurora cluster."
  value       = aws_rds_cluster.database.reader_endpoint
}

output "cluster_arn" {
  description = "The ARN of the Aurora cluster."
  value       = aws_rds_cluster.database.arn
}

output "cluster_id" {
  description = "The ID of the Aurora cluster."
  value       = aws_rds_cluster.database.id
}

output "db_subnet_group_name" {
  description = "The name of the DB subnet group."
  value       = aws_db_subnet_group.database.name
}
