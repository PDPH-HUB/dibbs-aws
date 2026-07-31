locals {
  github_role_name     = "${var.project}-github-role-${var.owner}-${random_string.oidc.result}"
  wildcard             = "*"
  resource_name_prefix = var.resource_name_prefix == "" ? local.wildcard : var.resource_name_prefix
}