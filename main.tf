# Make SSL certificate accessible
data "aws_acm_certificate" "this" {
  domain   = "pdphdibbs.phila.gov" # Cert Domain.
  types    = ["AMAZON_ISSUED"] # or ["ISSUED"] or ["PRIVATE"] #We can probably leave this out depending on who is providing it.
  statuses = ["ISSUED"]
}



data "aws_secretsmanager_secret" "secret_sql_database_user" {
  name = "SQL_DATABASE_USER"
}

data "aws_secretsmanager_secret_version" "secret-version-user" {
  secret_id = data.aws_secretsmanager_secret.secret_sql_database_user.id
}

data "aws_secretsmanager_secret" "secret_sql_database_host" {
  name = "SQL_DATABASE_HOST"
}

data "aws_secretsmanager_secret_version" "secret-version-host" {
  secret_id = data.aws_secretsmanager_secret.secret_sql_database_host.id
}

data "aws_secretsmanager_secret" "secret_sql_database_pass" {
  name = "SQL_DATABASE_PASS"
}

data "aws_secretsmanager_secret_version" "secret-version-pass" {
  secret_id = data.aws_secretsmanager_secret.secret_sql_database_pass.id
}

data "aws_secretsmanager_secret" "secret_nextauth_secret" {
  name = "AUTH_SECRET_VERSION"
}

data "aws_secretsmanager_secret_version" "secret-version-nextauth" {
  secret_id = data.aws_secretsmanager_secret.secret_nextauth_secret.id
}

data "aws_secretsmanager_secret" "secret_auth_client_secret_version" {
  name = "AUTH_CLIENT_SECRET_VERSION"
}

data "aws_secretsmanager_secret_version" "secret-version-authclient-secret" {
  secret_id = data.aws_secretsmanager_secret.secret_auth_client_secret_version.id
}

module "ecs" {
  
  source  = "CDCgov/dibbs-ecr-viewer/aws"
  version = "0.8.7"

  public_subnet_ids  = flatten([    
    "subnet-0b5f36d63e75c9194",
    "subnet-0e008a543ea2bba3f"
  ])

  private_subnet_ids = flatten([
    "subnet-01208b033707666bb",
    "subnet-033f13c263267da57"
  ])

  vpc_id             = "vpc-0170a65e2379f875e"
  region             = var.region

  owner   = var.owner
  project = var.project
  tags    = local.tags

  # Pass cert arn to module
  certificate_arn = data.aws_acm_certificate.this.arn
  database_type = "sqlserver"
  # secrets_manager_sqlserver_user_name = 
  # secrets_manager_sqlserver_password_name = 
  # secrets_manager_sqlserver_host_name = 


  secrets_manager_sqlserver_user_version = data.aws_secretsmanager_secret_version.secret-version-user.secret_string
  secrets_manager_sqlserver_host_version = data.aws_secretsmanager_secret_version.secret-version-host.secret_string
  secrets_manager_sqlserver_password_version = data.aws_secretsmanager_secret_version.secret-version-pass.secret_string
  db_cipher = "DEFAULT:@SECLEVEL=0"
  dibbs_config_name = "AWS_SQLSERVER_NON_INTEGRATED"

  # sqlserver_database_data = {
  #   non_integrated_viewer = "true"
  #   metadata_database_type = "sqlserver"
  #   metadata_database_schema = "extended" # (core or extended)
  # }
  
  # If intent is to pull from the phdi GHCR, set disable_ecr to true (default is false)
  # disable_ecr = true
  # If intent is to use the non-integrated viewer, set non_integrated_viewer to "true" (default is false)
  # non_integrated_viewer = "true"
  # If the intent is to make the ecr-viewer availabble on the public internet, set internal to false (default is true) This requires an internet gateway to be present in the VPC.
  # internal       = false
  internal       = true
  phdi_version = var.phdi_version

  # non integrated auth provider example (default values are "" when not set)
  auth_provider                              = "ad"
  auth_client_id                             = "910cc61a-9dcc-4cef-9fbe-2a9dcf87fbd9"
  auth_issuer                                = "2046864f-68ea-497d-af34-a6629a6cd700"
  auth_url                                   = "https://pdphdibbs.phila.gov/ecr-viewer/api/auth"
  secrets_manager_auth_secret_version        = data.aws_secretsmanager_secret_version.secret-version-nextauth.secret_string
  secrets_manager_auth_client_secret_version = data.aws_secretsmanager_secret_version.secret-version-authclient-secret.secret_string

  # Set Container Size
  override_autoscaling = {
    fhir-converter = {
    cpu = 2048
    memory = 4096
    max_capacity = 5
    min_capacity = 1
    target_cpu = 60
    target_memory = 70
    }
  }

}
