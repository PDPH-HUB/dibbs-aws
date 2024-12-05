# Make SSL certificate accessible
# data "aws_acm_certificate" "this" {
#   domain   = "internal-dibbs-ce-pdph-prod-1412429004.us-east-1.elb.amazonaws.com" # Cert Domain.
#   types    = ["AMAZON_ISSUED"] # or ["ISSUED"] or ["PRIVATE"] #We can probably leave this out depending on who is providing it.
#   statuses = ["ISSUED"]
# }


module "ecs" {
  
  
  source  = "CDCgov/dibbs-ecr-viewer/aws"
  version = "0.2.1"

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
  # certificate_arn = data.aws_acm_certificate.this.arn

  sqlserver_database_data = {
    non_integrated_viewer = "true"
    metadata_database_type = "sqlserver"
    metadata_database_schema = "extended" # (core or extended)
    secrets_manager_sqlserver_user_name = "SQL_DATABASE_USER"
    secrets_manager_sqlserver_password_name = "SQL_DATABASE_PASS"
    secrets_manager_sqlserver_host_name = "SQL_DATABASE_HOST"
  }

  


  # If intent is to pull from the phdi GHCR, set disable_ecr to true (default is false)
  # disable_ecr = true
  # If intent is to use the non-integrated viewer, set non_integrated_viewer to "true" (default is false)
  # non_integrated_viewer = "true"
  # If the intent is to make the ecr-viewer availabble on the public internet, set internal to false (default is true) This requires an internet gateway to be present in the VPC.
  # internal       = false
  internal       = true
  ecr_viewer_app_env = "test"
  phdi_version = "v1.7.5"
}
