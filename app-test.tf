# Find and replace "tfc-test2" with your chosen app tag.

# Run a plan and then an apply to create the Org & Workspaces.

# After creating workspaces, uncomment the secrets area.

# Run a new apply to create the environment/tf vars in each workspace.

locals {
  tfc-test2_org          = "tfc-test2"
  tfc-test2_app          = "tfc-test2-com"
  tfc-test2_email        = "tfc@zbmowrey.com"
  tfc-test2_environments = tolist(["develop", "staging", "main"])
}

# Create/manage the org.

resource "tfe_organization" "tfc-test2" {
  lifecycle {
    prevent_destroy = true
  }
  email = local.tfc-test2_email
  name  = local.tfc-test2_org
}

# Oauth really needs to be set up independently.

data "tfe_oauth_client" "tfc-test2" {
  oauth_client_id = "oc-s67mg9epNCX1QPkx"
}

# Create one workspace for any environment defined in terraform.auto.tfvars.

resource "tfe_workspace" "tfc-test2" {
  for_each                  = toset(local.tfc-test2_environments)
  name                      = "${local.tfc-test2_app}-${each.value}"
  organization              = tfe_organization.tfc-test2.name
  remote_state_consumer_ids = []
  trigger_prefixes          = []
  vcs_repo {
    identifier     = "${local.tfc-test2_org}/${local.tfc-test2_app}"
    oauth_token_id = data.tfe_oauth_client.tfc-test2.oauth_token_id
    branch         = each.value
  }
}

#data "tfe_workspace_ids" "tfc-test2-all" {
#  depends_on   = [tfe_workspace.tfc-test2]
#  organization = tfe_organization.tfc-test2.name
#  names        = ["*"]
#}
#
## Access keys for the various AWS environments.
#
#resource "tfe_variable" "tfc-test2-access-keys" {
#  depends_on   = [data.tfe_workspace_ids.tfc-test2-all]
#  for_each     = toset(local.tfc-test2_environments)
#  category     = "env"
#  key          = "AWS_ACCESS_KEY_ID"
#  value        = lookup(var.access_keys["aws"], each.value, { "access" : "access" })["access"]
#  workspace_id = lookup(data.tfe_workspace_ids.tfc-test2-all.ids, "${local.tfc-test2_app}-${each.value}")
#  sensitive    = true
#}
#
## Secret keys for the various AWS environments.
#
#resource "tfe_variable" "tfc-test2-secrets" {
#  depends_on   = [data.tfe_workspace_ids.tfc-test2-all]
#  for_each     = toset(local.tfc-test2_environments)
#  category     = "env"
#  key          = "AWS_SECRET_ACCESS_KEY"
#  value        = lookup(var.access_keys["aws"], each.value, { "secret" : "secret" })["secret"]
#  workspace_id = lookup(data.tfe_workspace_ids.tfc-test2-all.ids, "${local.tfc-test2_app}-${each.value}")
#  sensitive    = true
#}
#
## There is currently no CF Distribution for tfc-test2, but it's coming.
#
#resource "tfe_variable" "tfc-test2-cf-distributions" {
#  for_each     = lookup(var.cf_distribution,local.tfc-test2_org,{})
#  category     = "terraform"
#  key          = "cf_distribution"
#  value        = lookup(var.cf_distribution["tfc-test2"], each.key, "")
#  workspace_id = lookup(data.tfe_workspace_ids.tfc-test2-all.ids,"${local.tfc-test2_app}-${each.key}")
#}