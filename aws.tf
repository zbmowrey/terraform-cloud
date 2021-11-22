locals {
  aws_org          = "zbmowrey"
  aws_app          = "cloud-admin"
  aws_email        = "zbmowrey@gmail.com"
  aws_environments = tolist(["develop", "staging", "main"])
}

# This organization contains our state. It must not be destroyed.

resource "tfe_organization" "zbmowrey-cloud-admin" {
  lifecycle {
    prevent_destroy = true
  }
  email = local.aws_email
  name  = "zbmowrey-cloud-admin"
}

# Create one workspace for any environment defined in terraform.auto.tfvars.

data "tfe_oauth_client" "aws" {
  oauth_client_id = var.oauth_clients.zbmowrey
}

# Create one workspace for any environment defined in terraform.auto.tfvars.

resource "tfe_workspace" "aws" {
  name                      = "cloud-admin"
  organization              = tfe_organization.zbmowrey-cloud-admin.name
  vcs_repo {
    identifier     = "${local.aws_org}/${local.aws_app}"
    oauth_token_id = data.tfe_oauth_client.aws.oauth_token_id
    branch         = "main"
  }
}

# Access keys for the various AWS environments.

resource "tfe_variable" "aws-access-keys" {
  category     = "env"
  key          = "AWS_ACCESS_KEY_ID"
  value        = var.aws_root_key
  workspace_id = tfe_workspace.aws.id
  sensitive    = true
}

# Secret keys for the various AWS environments.

resource "tfe_variable" "aws-secret-keys" {
  for_each     = toset(local.aws_environments)
  category     = "env"
  key          = "AWS_SECRET_ACCESS_KEY"
  value        = var.aws_root_secret
  workspace_id = tfe_workspace.aws.id
  sensitive    = true
}
