locals {
  zbmowrey_app          = "zbmowrey-com"
  zbmowrey_environments = tolist(["develop", "staging", "main"])
}

# This organization contains our state. It must not be destroyed.

resource "tfe_organization" "zbmowrey" {
  lifecycle {
    prevent_destroy = true
  }
  email = "zbmowrey@gmail.com"
  name  = "zbmowrey"
}

# Create one workspace for any environment defined in terraform.auto.tfvars.

resource "tfe_workspace" "zbmowrey" {
  for_each            = toset(local.zbmowrey_environments)
  name                = "${local.zbmowrey_app}-${each.value}"
  description         = "https://zbmowrey.com ${each.value} environment"
  organization        = tfe_organization.zbmowrey.name
  working_directory   = "terraform"
  execution_mode      = "local"
  auto_apply          = false
}

resource "tfe_workspace" "insult-bot" {
  for_each            = toset(local.zbmowrey_environments)
  name                = "insult-bot-${each.value}"
  description         = "Slack Insult Bot ${each.value} environment"
  organization        = tfe_organization.zbmowrey.name
  execution_mode      = "local"
  auto_apply          = false
}

# Fetch all workspace ids for the org.

data "tfe_workspace_ids" "zbmowrey-all" {
  depends_on   = [tfe_workspace.zbmowrey]
  organization = tfe_organization.zbmowrey.name
  names        = ["*"]
}

# Apply Slack URL Notifications for all workspace ids.

resource "tfe_notification_configuration" "insult-slack" {
  for_each         = data.tfe_workspace_ids.zbmowrey-all.ids
  destination_type = "slack"
  enabled          = true
  url              = var.terraform_slack_url
  name             = "Terraform Cloud"
  workspace_id     = each.value
  triggers         = local.notification_triggers
}