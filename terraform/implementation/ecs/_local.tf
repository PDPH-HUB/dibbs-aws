locals {
  # unused: upstream uses this to name module "vpc" (not called here)
  # tflint-ignore: terraform_unused_declarations
  vpc_name = "${var.project}-${var.owner}-${terraform.workspace}"
  tags = {
    owner       = var.owner
    workspace   = terraform.workspace
    project     = var.project
    environment = terraform.workspace
  }
}
