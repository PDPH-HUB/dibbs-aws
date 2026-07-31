variable "oidc_github_repo" {
  description = "The GitHub repository for OIDC"
  type        = string
  default     = ""
}

variable "owner" {
  description = "The owner of the project"
  type        = string
  default     = "pdph"
}

variable "project" {
  description = "The name of the project"
  type        = string
  default     = "dibbs"
}

variable "region" {
  type        = string
  description = "The AWS region where resources are created"
  default     = "us-east-1"
}

variable "dev_vpc_id" {
  description = "VPC ID scoping the dev OIDC role's policies"
  type        = string
}

variable "prod_vpc_id" {
  description = "VPC ID scoping the prod OIDC role's policies"
  type        = string
}

variable "tfstate_bucket_arn" {
  description = "ARN of the existing tfstate S3 bucket (module \"tfstate\" not used, see main.tf)"
  type        = string
}

variable "tfstate_bucket_name" {
  description = "Name of the existing tfstate S3 bucket"
  type        = string
}

variable "tfstate_dynamodb_table_arn" {
  description = "ARN of the existing tfstate lock DynamoDB table"
  type        = string
}
