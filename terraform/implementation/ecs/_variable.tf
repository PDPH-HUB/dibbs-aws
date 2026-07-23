variable "availability_zones" {
  description = "The availability zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "owner" {
  description = "The owner of the infrastructure"
  type        = string
  default     = "pdph"
}

variable "phdi_version" {
  description = "PHDI container image version"
  type        = string
  default     = "8.1.0"
}

variable "ecr_viewer_database_schema" {
  description = "The database schema used for the eCR data tables"
  type        = string
  default     = "core"
}

variable "database_type" {
  description = "The type of database to use (postgresql or sqlserver or '')"
  type        = string
  default     = ""
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

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "176.31.0.0/16"
}

variable "vpc_id" {
  description = "ID for the VPC"
  type        = string
  default     = ""
}

variable "route53_hosted_zone_id" {
  description = "The Route53 hosted zone ID"
  type        = string
  default     = ""
  sensitive   = true
}

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

variable "auth_session_duration_min" {
  description = "Duration in minutes before auto signout, defaults to 30 if not set"
  type        = string
  default     = ""
}

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

variable "secrets_manager_metadata_database_migration_secret_version" {
  description = "The secret containing the db migration secret. This is used by eCR viewer to allow database migrations."
  type        = string
  default     = ""
  sensitive   = true
}

# Declared for structural parity with upstream. Deliberately NOT wired into
# main.tf's module "ecs" block -- this default is upstream's own example/demo
# key, not a PDPH key. Wiring it in would silently enable pub-key auth
# validation against a key nobody at PDPH controls. Leave unwired unless a
# real PDPH key is generated and this default is replaced first.
variable "nbs_pub_key" {
  type        = string
  description = "The public key used to validate the incoming authenication for the eCR Viewer."
  default     = <<EOT
-----BEGIN PUBLIC KEY-----
MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAnlA1YmmbydxQdBh7DAq0
wUfsjR25eWZOB995mHclT3C46oLat3YLu70akLfoMXd9YcJe0d4q3sP7tS1J4QDO
IkfapvK3ClDJR2VUERTzR9yQ+1B1Sd+MSful/V3aP9L6wPRAJmsmziizUBz+X0oN
WTkGP/xi0F/IlyBfh2sk89JKKmgXSFbgDTD7+8L5WeRY5koR0KfDJLBcyerrcIPW
1FyD8RbkUH78yJXc+/ThXKBNpsDTvV0k/4zqLSADIEmhQFkW8oYOfF4ufBGSnGdZ
gPoWbKHtlK+m1sFWMq0hAtJsNKsJQocPAEO2NIxRCX4k6X9HfvCYVniDI4OdVz0V
jTF+galQDAybgtYc9ZN8ROpePDVkCANHzniBJFOwzv2yekreqdX7M399uLB+ztDX
Iz2RpZbGkgspl4TWvvB+eN64DJykmExImIw1nFc/6AVd3jhKSnCrckpGV3XaF8lW
WMA6au0RXjmRa4YxO/uQbFZeFkM7aQtQK/CxqdBfG0SACcIMwU2S7Kb5+c9Hs687
LI8j7j0oVyCiAyJ44Mi70i4A2GedyM6kzdixTmszin+c4tT8mYjmEMpJle6GLBIa
aqEy3CVEqecFIo4ypfoo4GjTqvv/JjtxwBl1FPC+HzFkOjSoLbrDmn64NnQhXlC9
kd+ONf43CmqDSTa3atSFq4sCAwEAAQ==
-----END PUBLIC KEY-----
EOT
}

# Declared for structural parity with upstream. No current PDPH equivalent
# (module "db" is not called from main.tf -- see project plan Section 6.2).
# Kept unused, same treatment as database_type above, for upstream-diff
# friendliness rather than deletion.
variable "ssh_key_name" {
  description = "The name of the SSH key to use for the instances"
  type        = string
  default     = ""
}

# ------------------------------------------------------------------------------------------------------
# PDPH-specific: no upstream equivalent
# ------------------------------------------------------------------------------------------------------

variable "cert_name" {
  description = "SSL Certificate name"
  type        = string
}

variable "waf_web_acl_arn" {
  description = "Existing WAF Web ACL ARN to associate with ALB. If empty, a new ACL will be created."
  type        = string
  default     = ""
}

variable "db_cipher" {
  description = "Defines cipher string for NextJS communication with DB"
  type        = string
}

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

variable "enable_alb_logs" {
  type        = bool
  description = "Flag to enable ALB access and connection logging to s3 logging bucket"
  default     = true
}

variable "sql_connection_string" {
  description = "Full SQL Server connection string used by eCR Viewer to connect to the database."
  type        = string
  default     = ""
  sensitive   = true
}
