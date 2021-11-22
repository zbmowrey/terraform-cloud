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
  oauth_client_id = var.oauth_clients.aws
}

# Create one workspace for any environment defined in terraform.auto.tfvars.

resource "tfe_workspace" "aws" {
  for_each                  = toset(local.aws_environments)
  name                      = "${local.aws_app}-${each.value}"
  organization              = tfe_organization.zbmowrey-cloud-admin.name
  working_directory         = "terraform"
  remote_state_consumer_ids = []
  trigger_prefixes          = []
  vcs_repo {
    identifier     = "${local.aws_org}/${local.aws_app}"
    oauth_token_id = data.tfe_oauth_client.aws.oauth_token_id
    branch         = each.value
  }
}

data "tfe_workspace_ids" "aws-all" {
  depends_on   = [tfe_workspace.aws]
  organization = tfe_organization.zbmowrey-cloud-admin.name
  names        = ["*"]
}

# Access keys for the various AWS environments.

resource "tfe_variable" "aws-access-keys" {
  for_each     = toset(local.aws_environments)
  category     = "env"
  key          = "AWS_ACCESS_KEY_ID"
  value        = lookup(var.access_keys["aws"], each.value, { "access" : "access" })["access"]
  workspace_id = lookup(data.tfe_workspace_ids.aws-all.ids, "${local.aws_app}-${each.value}")
  sensitive    = true
}

# Secret keys for the various AWS environments.

resource "tfe_variable" "aws-secret-keys" {
  for_each     = toset(local.aws_environments)
  category     = "env"
  key          = "AWS_SECRET_ACCESS_KEY"
  value        = lookup(var.access_keys["aws"], each.value, { "secret" : "secret" })["secret"]
  workspace_id = lookup(data.tfe_workspace_ids.aws-all.ids, "${local.aws_app}-${each.value}")
  sensitive    = true
}

# Set this value because we'll want to invalidate these later.

resource "tfe_variable" "aws-cf-distributions" {
  for_each     = lookup(var.cf_distribution, local.aws_org, {})
  category     = "terraform"
  key          = "cf_distribution"
  value        = lookup(var.cf_distribution["aws"], each.key, "")
  workspace_id = lookup(data.tfe_workspace_ids.aws-all.ids, "${local.aws_app}-${each.key}")
}
