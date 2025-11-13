# Make SSL certificate accessible
data "aws_acm_certificate" "this" {
  domain   = var.cert_name
  types    = ["AMAZON_ISSUED"]
  statuses = ["ISSUED"]
}

data "aws_secretsmanager_secret" "secret_sql_connection_string" { 
  name = var.secret_manager__connection_string_version
}

data "aws_secretsmanager_secret_version" "connection_string_version" {
  secret_id = data.aws_secretsmanager_secret.secret_sql_connection_string.id
}

data "aws_secretsmanager_secret" "secret_nextauth_secret" { 
  name = var.secret_manager__auth_secret_version
}

data "aws_secretsmanager_secret_version" "secret-version-nextauth" {
  secret_id = data.aws_secretsmanager_secret.secret_nextauth_secret.id
}

data "aws_secretsmanager_secret" "secret_auth_client_secret_version" {
  name = var.secret_manager__auth_client_secret_version
}

data "aws_secretsmanager_secret_version" "secret-version-authclient-secret" {
  secret_id = data.aws_secretsmanager_secret.secret_auth_client_secret_version.id
}

module "ecs" {
  
  source  = "CDCgov/dibbs-ecr-viewer/aws"
  version = "0.9.0"

  public_subnet_ids  = flatten(var.public_subnets)

  private_subnet_ids = flatten(var.private_subnets)

  vpc_id             = var.vpc_id
  region             = var.region

  owner   = var.owner
  project = var.project
  tags    = local.tags

  # Pass cert arn to module
  certificate_arn = data.aws_acm_certificate.this.arn
  
  # database_type = var.ecr_viewer_database_type

  secrets_manager_connection_string_version = data.aws_secretsmanager_secret_version.connection_string_version.secret_string

  db_cipher = var.db_cipher
  dibbs_config_name = var.ecr_viewer_database_schema

  # If intent is to pull from the phdi GHCR, set disable_ecr to true (default is false)
  # disable_ecr = true
  # If intent is to use the non-integrated viewer, set non_integrated_viewer to "true" (default is false)
  # non_integrated_viewer = "true"
  # If the intent is to make the ecr-viewer availabble on the public internet, set internal to false (default is true) This requires an internet gateway to be present in the VPC.
  # internal       = false
  internal       = true
  phdi_version = var.phdi_version

  # non integrated auth provider example (default values are "" when not set)
  auth_provider                              = var.auth_provider
  auth_client_id                             = var.auth_client_id
  auth_issuer                                = var.auth_issuer
  auth_url                                   = var.auth_url
  secrets_manager_auth_secret_version        = data.aws_secretsmanager_secret_version.secret-version-nextauth.secret_string
  secrets_manager_auth_client_secret_version = data.aws_secretsmanager_secret_version.secret-version-authclient-secret.secret_string

  # Set Container Size
  override_autoscaling = {
    # Define fhir converter resources
    fhir-converter = var.task_size_overrides[0]
  }

  # Logging for ALB
  enable_alb_logs = var.enable_alb_logs
  s3_logging_bucket_name = local.s3_logging_bucket_name

}
