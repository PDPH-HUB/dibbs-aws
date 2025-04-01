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

variable "owner" {
  description = "The owner of the infrastructure"
  type        = string
  default     = "alis"
}

# Manually update to set the version you want to run
variable "phdi_version" {
  description = "PHDI container image version"
  type        = string
  default     = "v1.7.6"
}

variable "private_subnets" {
  description = "The private subnets"
  type        = list(string)
  default     = ["176.31.1.0/24", "176.31.3.0/24"]
}

variable "project" {
  description = "The project name"
  type        = string
  default     = "dibbs"
}

variable "public_subnets" {
  description = "The public subnets"
  type        = list(string)
  default     = ["176.31.2.0/24", "176.31.4.0/24"]
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "single_nat_gateway" {
  description = "Single NAT Gateway"
  type        = bool
  default     = false
}

variable "vpc" {
  description = "The name of the VPC"
  type        = string
  default     = "ecs-vpc"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "176.31.0.0/16"
}

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

locals {
  vpc_name = "${var.project}-${var.owner}-${terraform.workspace}"
  tags = {
    project   = var.project
    owner     = var.owner
    workspace = terraform.workspace
  }
}

variable "auth_provider" {
  description = "The authentication provider used. Either keycloak or ad."
  type        = string
  default     = ""
}

variable "auth_client_id" {
  description = "The application/client id used to idenitfy the client"
  type        = string
  default     = ""
}

variable "auth_issuer" {
  description = "Additional information used during authentication process. For Azure AD, this will be the 'Tenant Id'. For Keycloak, this will be the url issuer including the realm - e.g. https://my-keycloak-domain.com/realms/My_Realm"
  type        = string
  default     = ""
}