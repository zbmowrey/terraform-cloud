# Find and replace "template" with your chosen app tag.

# Run a plan and then an apply to create the Org & Workspaces.

# After creating workspaces, uncomment the secrets area.

# Run a new apply to create the environment/tf vars in each workspace.

locals {
  tomatowarning_org          = "tomatowarning"
  tomatowarning_app          = "tomatowarning-com"
  tomatowarning_email        = "tfc@zbmowrey.com"
  tomatowarning_environments = tolist(["develop", "staging", "main"])
}

# Create/manage the org.

resource "tfe_organization" "tomatowarning" {
  lifecycle {
    prevent_destroy = true
  }
  email = local.tomatowarning_email
  name  = local.tomatowarning_org
}

# Oauth really needs to be set up independently.

data "tfe_oauth_client" "tomatowarning" {
  oauth_client_id = var.oauth_clients.tomatowarning
}

# Create one workspace for any environment defined in terraform.auto.tfvars.

resource "tfe_workspace" "tomatowarning" {
  for_each          = toset(local.tomatowarning_environments)
  name              = "${local.tomatowarning_app}-${each.value}"
  organization      = tfe_organization.tomatowarning.name
  working_directory = "terraform"
  vcs_repo {
    identifier     = "${local.tomatowarning_org}/${local.tomatowarning_app}"
    oauth_token_id = data.tfe_oauth_client.tomatowarning.oauth_token_id
    branch         = each.value
  }
}

resource "tfe_notification_configuration" "tomatowarning-slack" {
  for_each         = toset(local.tomatowarning_environments)
  destination_type = "slack"
  enabled          = true
  url              = var.terraform_slack_url
  name             = "Terraform Cloud"
  workspace_id     = lookup(data.tfe_workspace_ids.tomatowarning-all.ids, "${local.tomatowarning_app}-${each.value}")
  triggers         = ["run:needs_attention", "run:errored"]
}

data "tfe_workspace_ids" "tomatowarning-all" {
  depends_on   = [tfe_workspace.tomatowarning]
  organization = tfe_organization.tomatowarning.name
  names        = ["*"]
}

# Access keys for the various AWS environments.

resource "tfe_variable" "tomatowarning-access-keys" {
  depends_on   = [data.tfe_workspace_ids.tomatowarning-all]
  for_each     = toset(local.tomatowarning_environments)
  category     = "env"
  key          = "AWS_ACCESS_KEY_ID"
  value        = lookup(var.access_keys["aws"], each.value, { "access" : "access" })["access"]
  workspace_id = lookup(data.tfe_workspace_ids.tomatowarning-all.ids, "${local.tomatowarning_app}-${each.value}")
  sensitive    = true
}

# Secret keys for the various AWS environments.

resource "tfe_variable" "tomatowarning-secrets" {
  depends_on   = [data.tfe_workspace_ids.tomatowarning-all]
  for_each     = toset(local.tomatowarning_environments)
  category     = "env"
  key          = "AWS_SECRET_ACCESS_KEY"
  value        = lookup(var.access_keys["aws"], each.value, { "secret" : "secret" })["secret"]
  workspace_id = lookup(data.tfe_workspace_ids.tomatowarning-all.ids, "${local.tomatowarning_app}-${each.value}")
  sensitive    = true
}

# There is currently no CF Distribution for TomatoWarning, but it's coming.

resource "tfe_variable" "tomatowarning-cf-distributions" {
  for_each     = lookup(var.cf_distribution, local.tomatowarning_org, {})
  category     = "terraform"
  key          = "cf_distribution"
  value        = lookup(var.cf_distribution["tomatowarning"], each.key, "")
  workspace_id = lookup(data.tfe_workspace_ids.tomatowarning-all.ids, "${local.tomatowarning_app}-${each.key}")
}