# removed, unused in our environment (tfstate backend already exists)
# resource "random_string" "setup" {
#   length  = 8
#   special = false
#   upper   = false
# }
#
# module "tfstate" {
#   source     = "../../modules/tfstate"
#   identifier = random_string.setup.result
#   owner      = var.owner
#   project    = var.project
# }

# GitHub OIDC for dev
module "oidc_dev" {
  source = "../../modules/oidc"

  oidc_github_repo = var.oidc_github_repo

  region  = var.region
  owner   = var.owner
  project = var.project

  resource_tag_to_match = "workspace"
  workspace             = "dev"
  resource_name_prefix  = var.dev_resource_name_prefix

  route53_hosted_zone_arn = var.dev_route53_hosted_zone_arn
  waf_web_acl_arn         = var.dev_waf_web_acl_arn

  state_bucket_arn   = var.tfstate_bucket_arn
  dynamodb_table_arn = var.tfstate_dynamodb_table_arn
}

# GitHub OIDC for prod
module "oidc_prod" {
  source = "../../modules/oidc"

  oidc_github_repo = var.oidc_github_repo

  region  = var.region
  owner   = var.owner
  project = var.project

  resource_tag_to_match = "workspace"
  workspace             = "prod"
  resource_name_prefix  = var.prod_resource_name_prefix

  route53_hosted_zone_arn = var.prod_route53_hosted_zone_arn
  waf_web_acl_arn         = var.prod_waf_web_acl_arn

  state_bucket_arn   = var.tfstate_bucket_arn
  dynamodb_table_arn = var.tfstate_dynamodb_table_arn
}

resource "local_file" "setup_env" {
  content  = <<-EOT
    WORKSPACE="${terraform.workspace}"
    BUCKET="${var.tfstate_bucket_name}"
    DYNAMODB_TABLE="${var.tfstate_dynamodb_table_arn}"
    REGION="${var.region}"
    TERRAFORM_ROLES="${module.oidc_dev.role.arn} ${module.oidc_prod.role.arn}"
  EOT
  filename = ".env"
}