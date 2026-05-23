output "db_endpoint" {
  description = "The endpoint of the RDS instance."
  value       = aws_db_instance.database.endpoint
}

output "db_arn" {
  description = "The ARN of the RDS instance."
  value       = aws_db_instance.database.arn
}

output "db_id" {
  description = "The ID of the RDS instance."
  value       = aws_db_instance.database.id
}

output "db_subnet_group_name" {
  description = "The name of the DB subnet group."
  value       = aws_db_subnet_group.database.name
}
