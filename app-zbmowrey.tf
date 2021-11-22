locals {
  zbmowrey_org          = "zbmowrey"
  zbmowrey_app          = "zbmowrey-com"
  zbmowrey_email        = "zbmowrey@gmail.com"
  zbmowrey_environments = tolist(["develop", "staging", "main"])
}

# This organization contains our state. It must not be destroyed.

resource "tfe_organization" "zbmowrey" {
  lifecycle {
    prevent_destroy = true
  }
  email = local.zbmowrey_email
  name  = local.zbmowrey_org
}

# Create one workspace for any environment defined in terraform.auto.tfvars.

data "tfe_oauth_client" "zbmowrey" {
  oauth_client_id = var.oauth_clients.zbmowrey
}

# Create one workspace for any environment defined in terraform.auto.tfvars.

resource "tfe_workspace" "zbmowrey" {
  for_each                  = toset(local.zbmowrey_environments)
  name                      = "${local.zbmowrey_app}-${each.value}"
  organization              = tfe_organization.zbmowrey.name
  working_directory         = "terraform"
  remote_state_consumer_ids = []
  trigger_prefixes          = []
  vcs_repo {
    identifier     = "${local.zbmowrey_org}/${local.zbmowrey_app}"
    oauth_token_id = data.tfe_oauth_client.zbmowrey.oauth_token_id
    branch         = each.value
  }
}

data "tfe_workspace_ids" "zbmowrey-all" {
  depends_on   = [tfe_workspace.zbmowrey]
  organization = tfe_organization.zbmowrey.name
  names        = ["*"]
}

# Access keys for the various AWS environments.

resource "tfe_variable" "zbmowrey-access-keys" {
  for_each     = toset(local.zbmowrey_environments)
  category     = "env"
  key          = "AWS_ACCESS_KEY_ID"
  value        = lookup(var.access_keys["aws"], each.value, { "access" : "access" })["access"]
  workspace_id = lookup(data.tfe_workspace_ids.zbmowrey-all.ids, "${local.zbmowrey_app}-${each.value}")
  sensitive    = true
}

# Secret keys for the various AWS environments.

resource "tfe_variable" "zbmowrey-secret-keys" {
  for_each     = toset(local.zbmowrey_environments)
  category     = "env"
  key          = "AWS_SECRET_ACCESS_KEY"
  value        = lookup(var.access_keys["aws"], each.value, { "secret" : "secret" })["secret"]
  workspace_id = lookup(data.tfe_workspace_ids.zbmowrey-all.ids, "${local.zbmowrey_app}-${each.value}")
  sensitive    = true
}

# Set this value because we'll want to invalidate these later.

resource "tfe_variable" "zbmowrey-cf-distributions" {
  for_each     = lookup(var.cf_distribution, local.zbmowrey_org, {})
  category     = "terraform"
  key          = "cf_distribution"
  value        = lookup(var.cf_distribution["zbmowrey"], each.key, "")
  workspace_id = lookup(data.tfe_workspace_ids.zbmowrey-all.ids, "${local.zbmowrey_app}-${each.key}")
}