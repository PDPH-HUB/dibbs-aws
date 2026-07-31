output "oidc_dev_role_arn" {
  value = module.oidc_dev.role.arn
}

output "oidc_prod_role_arn" {
  value = module.oidc_prod.role.arn
}
