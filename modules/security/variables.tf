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

variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string
}

variable "app_port" {
  description = "The port the application listens on."
  type        = number
  default     = 80
}
