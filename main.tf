terraform {
  required_providers {
    tfe = {
      version = "~> 0.26.0"
    }
  }
  backend "remote" {
    organization = "zbmowrey-cloud-admin"

    workspaces {
      name = "terraform-cloud"
    }
  }
}

locals {
  notification_triggers = ["run:needs_attention", "run:planning", "run:completed", "run:errored"]
  foo = "bar"
}

provider "tfe" {
  token = var.access_keys["tf_cloud"]
}

resource "tfe_workspace" "terraform-cloud" {
  name                = "terraform-cloud"
  description         = "Manages all Terraform Cloud organizations, workspaces, and variables."
  organization        = tfe_organization.zbmowrey-cloud-admin.name
  vcs_repo {
    identifier     = "zbmowrey/terraform-cloud"
    oauth_token_id = data.tfe_oauth_client.cloud-admin.oauth_token_id
    branch         = "main"
  }
  auto_apply          = true
  speculative_enabled = true
}

resource "tfe_notification_configuration" "terraform-cloud" {
  destination_type = "slack"
  enabled          = true
  url              = var.terraform_slack_url
  name             = "Terraform Cloud"
  workspace_id     = tfe_workspace.terraform-cloud.id
  triggers         = local.notification_triggers
}