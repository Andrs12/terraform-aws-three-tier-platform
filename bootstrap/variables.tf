variable "project_name" {
  description = "Project identifier, used as a prefix for resource names."
  type        = string
  default     = "three-tier-platform"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,30}[a-z0-9]$", var.project_name))
    error_message = "project_name must be lowercase, start with a letter, and contain only letters, digits, and hyphens."
  }
}

variable "aws_region" {
  description = "AWS region where the state bucket and lock table are created."
  type        = string
  default     = "eu-west-1"
}

variable "aws_account_id" {
  description = "AWS account ID, appended to the bucket name to ensure global uniqueness."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "aws_account_id must be a 12-digit number."
  }
}

variable "owner" {
  description = "Team or person responsible for the infrastructure."
  type        = string
  default     = "platform-team"
}

variable "github_repos" {
  description = "GitHub repos allowed to assume the OIDC role (org/repo format)."
  type        = list(string)
  default     = ["YourGitHubOrg/terraform-aws-three-tier-platform"]
}