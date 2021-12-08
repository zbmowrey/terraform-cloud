locals {
  repsales_app          = "repsales-net"
  repsales_environments = tolist(["develop", "staging", "main"])
}

resource "tfe_organization" "repsales" {
  lifecycle {
    prevent_destroy = true
  }
  email = "tfc@zbmowrey.com"
  name  = "repsales"
}

resource "tfe_workspace" "repsales" {
  for_each            = toset(local.repsales_environments)
  name                = "${local.repsales_app}-${each.value}"
  description         = "https://repsales.net ${each.value} environment"
  organization        = tfe_organization.repsales.name
  execution_mode      = "local"
}

#data "tfe_workspace_ids" "repsales-all" {
#  depends_on   = [tfe_workspace.repsales]
#  organization = tfe_organization.repsales.name
#  names        = ["*"]
#}
#
## Apply the Slack Notification Config to each created workspace in this Org.
#
#resource "tfe_notification_configuration" "repsales-slack" {
#  for_each         = data.tfe_workspace_ids.repsales-all.ids
#  destination_type = "slack"
#  enabled          = true
#  url              = var.terraform_slack_url
#  name             = "Terraform Cloud"
#  workspace_id     = each.value
#  triggers         = local.notification_triggers
#}
