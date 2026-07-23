data "aws_acm_certificate" "this" {
  domain   = var.cert_name
  types    = ["AMAZON_ISSUED"]
  statuses = ["ISSUED"]
}

module "ecs" {
  source = "git::https://github.com/CDCgov/terraform-aws-dibbs-ecr-viewer.git?ref=292d3057adf75303689deeedd89b46c3462faf27"

  public_subnet_ids  = flatten(var.public_subnets)
  private_subnet_ids = flatten(var.private_subnets)

  vpc_id = var.vpc_id
  region = var.region

  owner   = var.owner
  project = var.project
  tags    = local.tags

  # So allow URI path rule doesn't get tossed out:
  waf_web_acl_arn = var.waf_web_acl_arn

  # Pass cert arn to module
  certificate_arn = data.aws_acm_certificate.this.arn

  db_cipher         = var.db_cipher
  dibbs_config_name = var.ecr_viewer_database_schema

  disable_ecr = false

  internal = true

  phdi_version = var.phdi_version

  auth_provider              = var.auth_provider
  auth_client_id             = var.auth_client_id
  auth_issuer                = var.auth_issuer
  auth_url                   = var.auth_url
  auth_session_duration_min  = var.auth_session_duration_min

  # GitHub Actions secrets, injected as plaintext ECS environment variables at apply time
  secrets_manager_connection_string_version                   = var.sql_connection_string
  secrets_manager_auth_secret_version                         = var.nextauth_secret
  secrets_manager_auth_client_secret_version                  = var.auth_client_secret
  secrets_manager_metadata_database_migration_secret_version  = var.secrets_manager_metadata_database_migration_secret_version

  # ecr_viewer_auth_pub_key / ecr_viewer_auth_api_pub_key intentionally
  # NOT set here. See the warning on var.nbs_pub_key in _variable.tf --
  # PDPH does not currently use pub-key auth validation, and wiring this
  # in would silently enable it against upstream's example key.

  # Set Container Size
  override_autoscaling = {
    ecr-viewer             = var.task_size_overrides[0]
    fhir-converter         = var.task_size_overrides[1]
    ingestion              = var.task_size_overrides[2]
    message-parser         = var.task_size_overrides[3]
    orchestration          = var.task_size_overrides[4]
    trigger-code-reference = var.task_size_overrides[5]
  }

  # Logging for ALB
  enable_alb_logs        = var.enable_alb_logs
  s3_logging_bucket_name = "${var.project}-${var.owner}-${terraform.workspace}-logging-bucket"

  # Timeouts
  alb_idle_timeout       = 3600    # seconds
  ecr_processing_timeout = 3600000 # miliseconds

  # Explicitly set to match current effective values
  cw_retention_in_days                  = 365
  ecr_viewer_object_retention_days      = 365
  logging_object_retention_days         = 365
  enable_alb_deletion_protection        = true
  enable_enhanced_ecr_registry_scanning = false
}

data "aws_lb" "ecs" {
  arn = module.ecs.alb_arn
}

resource "aws_route53_record" "alb" {
  zone_id = var.route53_hosted_zone_id
  name    = var.cert_name
  type    = "A"

  alias {
    name                   = module.ecs.alb_dns_name
    zone_id                = data.aws_lb.ecs.zone_id
    evaluate_target_health = true
  }
}
