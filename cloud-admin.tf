locals {
  cloud-admin_org          = "zbmowrey"
  cloud-admin_app          = "cloud-admin"
  cloud-admin_email        = "zbmowrey@gmail.com"
}

# This organization contains our state. It must not be destroyed.

resource "tfe_organization" "zbmowrey-cloud-admin" {
  lifecycle {
    prevent_destroy = true
  }
  email = local.cloud-admin_email
  name  = "zbmowrey-cloud-admin"
}

# Create one workspace for any environment defined in terraform.auto.tfvars.

data "tfe_oauth_client" "cloud-admin" {
  oauth_client_id = var.oauth_clients.zbmowrey
}

# Create one workspace for any environment defined in terraform.auto.tfvars.

resource "tfe_workspace" "cloud-admin" {
  name                      = "cloud-admin"
  organization              = tfe_organization.zbmowrey-cloud-admin.name
#  vcs_repo {
#    identifier     = "${local.cloud-admin_org}/${local.cloud-admin_app}"
#    oauth_token_id = data.tfe_oauth_client.cloud-admin.oauth_token_id
#    branch         = "main"
#  }
}

# Access keys for the various cloud-admin environments.

resource "tfe_variable" "cloud-admin-access-keys" {
  category     = "env"
  key          = "AWS_ACCESS_KEY_ID"
  value        = var.aws_root_key
  workspace_id = tfe_workspace.cloud-admin.id
  sensitive    = true
}

# Secret keys for the various cloud-admin environments.

resource "tfe_variable" "cloud-admin-secret-keys" {
  category     = "env"
  key          = "AWS_SECRET_ACCESS_KEY"
  value        = var.aws_root_secret
  workspace_id = tfe_workspace.cloud-admin.id
  sensitive    = true
}
