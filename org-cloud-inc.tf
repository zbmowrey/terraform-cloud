locals {
  cloud-inc_app          = "cloud-inc"
  cloud-inc_environments = tolist(["dev", "prod"])
}

# This organization contains our state. It must not be destroyed.
resource "tfe_organization" "cloud-inc" {
  lifecycle {
    prevent_destroy = true
  }
  email = "tfcloud@cloud.inc"
  name  = "cloud-inc"
}

# Create one workspace for any environment defined in terraform.auto.tfvars.

resource "tfe_workspace" "cloud-inc" {
  for_each            = toset(local.cloud-inc_environments)
  name                = "${local.cloud-inc_app}-${each.value}"
  description         = "https://cloud.inc ${each.value} environment"
  organization        = tfe_organization.cloud-inc.name
  working_directory   = "terraform"
  execution_mode      = "local"
  auto_apply          = false
  terraform_version = var.terraform_version
}