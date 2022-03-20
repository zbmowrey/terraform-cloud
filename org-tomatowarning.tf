locals {
  tomatowarning_app          = "tomatowarning-com"
  tomatowarning_environments = tolist(["develop", "staging", "main"])
}

resource "tfe_organization" "tomatowarning" {
  lifecycle {
    prevent_destroy = true
  }
  email = "tfc@zbmowrey.com"
  name  = "tomatowarning"
}

resource "tfe_workspace" "tomatowarning" {
  for_each          = toset(local.tomatowarning_environments)
  name              = "${local.tomatowarning_app}-${each.value}"
  description       = "https://tomatowarning.com ${each.value} environment"
  organization      = tfe_organization.tomatowarning.name
  working_directory = "terraform"
  execution_mode    = "local"
  auto_apply        = false
  terraform_version = var.terraform_version
}

data "tfe_workspace_ids" "tomatowarning-all" {
  depends_on   = [tfe_workspace.tomatowarning]
  organization = tfe_organization.tomatowarning.name
  names        = ["*"]
}

# Apply the Slack Notification Config to each created workspace in this Org.

resource "tfe_notification_configuration" "tomatowarning-slack" {
  for_each         = data.tfe_workspace_ids.tomatowarning-all.ids
  destination_type = "slack"
  enabled          = true
  url              = var.terraform_slack_url
  name             = "Terraform Cloud"
  workspace_id     = each.value
  triggers         = local.notification_triggers
}
