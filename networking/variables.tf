variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "project_name" {
  description = "Project identifier, used as a prefix for resource names."
  type        = string
}

variable "azs" {
  description = "List of availability zones to use for subnets."
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b"]
}
