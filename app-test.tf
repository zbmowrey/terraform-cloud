# Find and replace "tfc-test" with your chosen app tag.

# Run a plan and then an apply to create the Org & Workspaces.

# After creating workspaces, uncomment the secrets area.

# Run a new apply to create the environment/tf vars in each workspace.

locals {
  tfc-test_org          = "tfc-test"
  tfc-test_app          = "tfc-test-com"
  tfc-test_email        = "tfc@zbmowrey.com"
  tfc-test_environments = tolist(["develop", "staging", "main"])
}

# Create/manage the org.

resource "tfe_organization" "tfc-test" {
  lifecycle {
    prevent_destroy = true
  }
  email = local.tfc-test_email
  name  = local.tfc-test_org
}

# Oauth really needs to be set up independently.

data "tfe_oauth_client" "tfc-test" {
  oauth_client_id = "oc-FiwAHfUuLXjwRcUT"
}

# Create one workspace for any environment defined in terraform.auto.tfvars.

resource "tfe_workspace" "tfc-test" {
  for_each                  = toset(local.tfc-test_environments)
  name                      = "${local.tfc-test_app}-${each.value}"
  organization              = tfe_organization.tfc-test.name
  remote_state_consumer_ids = []
  trigger_prefixes          = []
  vcs_repo {
    identifier     = "${local.tfc-test_org}/${local.tfc-test_app}"
    oauth_token_id = data.tfe_oauth_client.tfc-test.oauth_token_id
    branch         = each.value
  }
}

data "tfe_workspace_ids" "tfc-test-all" {
  depends_on   = [tfe_workspace.tfc-test]
  organization = tfe_organization.tfc-test.name
  names        = ["*"]
}

# Access keys for the various AWS environments.

resource "tfe_variable" "tfc-test-access-keys" {
  depends_on   = [data.tfe_workspace_ids.tfc-test-all]
  for_each     = toset(local.tfc-test_environments)
  category     = "env"
  key          = "AWS_ACCESS_KEY_ID"
  value        = lookup(var.access_keys["aws"], each.value, { "access" : "access" })["access"]
  workspace_id = lookup(data.tfe_workspace_ids.tfc-test-all.ids, "${local.tfc-test_app}-${each.value}")
  sensitive    = true
}

# Secret keys for the various AWS environments.

resource "tfe_variable" "tfc-test-secrets" {
  depends_on   = [data.tfe_workspace_ids.tfc-test-all]
  for_each     = toset(local.tfc-test_environments)
  category     = "env"
  key          = "AWS_SECRET_ACCESS_KEY"
  value        = lookup(var.access_keys["aws"], each.value, { "secret" : "secret" })["secret"]
  workspace_id = lookup(data.tfe_workspace_ids.tfc-test-all.ids, "${local.tfc-test_app}-${each.value}")
  sensitive    = true
}

# There is currently no CF Distribution for tfc-test, but it's coming.

resource "tfe_variable" "tfc-test-cf-distributions" {
  for_each     = lookup(var.cf_distribution,local.tfc-test_org,{})
  category     = "terraform"
  key          = "cf_distribution"
  value        = lookup(var.cf_distribution["tfc-test"], each.key, "")
  workspace_id = lookup(data.tfe_workspace_ids.tfc-test-all.ids,"${local.tfc-test_app}-${each.key}")
}