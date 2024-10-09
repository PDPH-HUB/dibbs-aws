module "ecs" {
  source = "github.com/CDCgov/dibbs-aws//terraform/modules/ecs?ref=b80e6ebd89b0aeed0652b4678102378598865a3e"

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

  # If intent is to pull from the phdi GHCR, set disable_ecr to true (default is false)
  # disable_ecr = true
  # If intent is to use the non-integrated viewer, set non_integrated_viewer to "true" (default is false)
  # non_integrated_viewer = "true"
  # If the intent is to make the ecr-viewer availabble on the public internet, set internal to false (default is true) This requires an internet gateway to be present in the VPC.
  # internal       = false
  internal       = true
  non_integrated_viewer = "true"
  ecr_viewer_app_env = "test"
}
