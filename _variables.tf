# ------------------------------------------------------------------------------------------------------
# Project Naming Configurations
# ------------------------------------------------------------------------------------------------------
# These configure project naming conventions
# ------------------------------------------------------------------------------------------------------

variable "owner" {
  description = "The owner of the infrastructure"
  type        = string
  default     = "pdph"
}

variable "project" {
  description = "The project name"
  type        = string
  default     = "dibbs"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

locals {
  vpc_name = "${var.project}-${var.owner}-${terraform.workspace}"
  tags = {
    project   = var.project
    owner     = var.owner
    workspace = terraform.workspace
  }
  s3_logging_bucket_name = "${var.project}-${var.owner}-${terraform.workspace}-logging-bucket"
}

# ------------------------------------------------------------------------------------------------------
# Network Configurations
# ------------------------------------------------------------------------------------------------------
# These manage network configurations for AWS
# ------------------------------------------------------------------------------------------------------

variable "public_subnets" {
  description = "The public subnets"
  type        = list(string)
  default     = ["176.31.2.0/24", "176.31.4.0/24"]
}

variable "private_subnets" {
  description = "The private subnets"
  type        = list(string)
  default     = ["176.31.1.0/24", "176.31.3.0/24"]
}

variable "availability_zones" {
  description = "The availability zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "create_internet_gateway" {
  type        = bool
  description = "Flag to determine if an internet gateway should be created"
  default     = false
}

variable "ecs_alb_sg" {
  description = "The security group for the Application Load Balancer"
  type        = string
  default     = "ecs-albsg"
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Single NAT Gateway"
  type        = bool
  default     = false
}

/*
variable "vpc" {
  description = "The name of the VPC"
  type        = string
  default     = "ecs-vpc"
}
*/

/*
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "176.31.0.0/16"
}
*/

variable "vpc_id" {
  description = "ID for the VPC"
  type        = string
  default     = ""
}

variable "cert_name" {
  description = "SSL Certificate name"
  type        = string
}

variable "waf_web_acl_arn" {
  description = "Existing WAF Web ACL ARN to associate with ALB. If empty, a new ACL will be created."
  type        = string
  default     = ""
}

# ------------------------------------------------------------------------------------------------------
# Application Configurations
# ------------------------------------------------------------------------------------------------------
# This defines the application version being deployed and the resources they're deployed with
# ------------------------------------------------------------------------------------------------------

variable "task_size_overrides" {
  description = "Variable to overide task sizes"
  type = list(

    object({
      cpu           = number
      memory        = number
      max_capacity  = number
      min_capacity  = number
      target_cpu    = number
      target_memory = number
    })

  )
}

# Manually update to set the version you want to run
variable "phdi_version" {
  description = "PHDI container image version"
  type        = string
  default     = "8.1.0"
}

variable "enable_alb_logs" {
  type        = bool
  description = "Flag to enable ALB access and connection logging to s3 logging bucket"
  default     = true
}

variable "s3_logging_bucket_name" {
  type        = string
  description = "Name of the S3 bucket for logging"
  default     = ""
}

# ------------------------------------------------------------------------------------------------------
# Database Configurations
# ------------------------------------------------------------------------------------------------------
# These define the database configurations for the ECR viewer
# This does not include secrets for connecting to the database itself
# ------------------------------------------------------------------------------------------------------

variable "ecr_viewer_database_type" {
  description = "The SQL variant used for the eCR data tables"
  type        = string
  default     = "postgres"
}

variable "ecr_viewer_database_schema" {
  description = "The database schema used for the eCR data tables"
  type        = string
  default     = "core"
}

variable "db_cipher" {
  description = "Defines cipher string for NextJS communication with DB"
  type        = string
}

# ------------------------------------------------------------------------------------------------------
# Authentication Details
# ------------------------------------------------------------------------------------------------------
# These define the connection with our auth provided
# ------------------------------------------------------------------------------------------------------


variable "auth_provider" {
  type        = string
  default     = "ad"
  description = "The authentication provider used. Either keycloak or ad."
}

variable "auth_client_id" {
  type        = string
  default     = ""
  description = "The application/client id used to idenitfy the client"
}

variable "auth_issuer" {
  type        = string
  default     = ""
  description = "Additional information used during authentication process. For Azure AD, this will be the 'Tenant Id'. For Keycloak, this will be the url issuer including the realm - e.g. https://my-keycloak-domain.com/realms/My_Realm"
}

variable "auth_url" {
  type        = string
  default     = ""
  description = "Optional. The full URL of the auth api. By default https://your-site.com/ecr-viewer/api/auth."
}

# ------------------------------------------------------------------------------------------------------
# GitHub Secrets References
# ------------------------------------------------------------------------------------------------------
# These reference secrets managed in GitHub Actions (repo/environment secrets), passed in at
# terraform apply time via TF_VAR_* environment variables. NOTE: these are injected as plaintext
# environment variables into the ECS task definitions by the ecr-viewer module, not resolved via
# AWS Secrets Manager at runtime, despite the module's own upstream variable naming implying otherwise.
# ------------------------------------------------------------------------------------------------------

variable "nextauth_secret" {
  description = "Encryption key used by eCR Viewer to encrypt session authentication (NEXTAUTH_SECRET). Generated via `openssl rand -base64 32`, not related to the auth provider's client secret."
  type        = string
  sensitive   = true
  default     = ""
}

variable "auth_client_secret" {
  description = "Client secret issued by the authentication provider (Azure AD / Keycloak) for this application's registered client."
  type        = string
  sensitive   = true
  default     = ""
}

variable "sql_connection_string" {
  description = "Full SQL Server connection string used by eCR Viewer to connect to the database."
  type        = string
  default     = ""
  sensitive   = true
}