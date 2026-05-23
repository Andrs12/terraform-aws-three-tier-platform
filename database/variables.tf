variable "project_name" {
  description = "Project identifier, used as a prefix for resource names."
  type        = string
}

variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "eu-west-1"
}

variable "owner" {
  description = "Team or person responsible for the infrastructure."
  type        = string
  default     = "platform-team"
}

variable "database_subnet_ids" {
  description = "List of database subnet IDs."
  type        = list(string)
}

variable "rds_security_group_id" {
  description = "The ID of the RDS security group."
  type        = string
}

variable "db_name" {
  description = "Name of the database to create."
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Master username for the database."
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "Master password for the database."
  type        = string
  sensitive   = true
}

variable "instance_class" {
  description = "Instance class for the Aurora instances."
  type        = string
  default     = "db.serverless"
}

variable "instance_count" {
  description = "Number of Aurora instances (1 writer + N-1 readers)."
  type        = number
  default     = 1
}

variable "deletion_protection" {
  description = "Enable deletion protection for the database."
  type        = bool
  default     = false
}
