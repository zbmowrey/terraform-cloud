# This organization contains our state. It must not be destroyed.

resource "tfe_organization" "zbmowrey-cloud-admin" {
  lifecycle {
    prevent_destroy = true
  }
  email = "zbmowrey@gmail.com"
  name  = "zbmowrey-cloud-admin"
}

# Terraform Cloud - Used for remote state on all other projects. Used for remote state & deploy
# on the terraform-cloud project.

data "tfe_oauth_client" "cloud-admin" {
  oauth_client_id = var.oauth_clients.cloud-admin
}

resource "tfe_workspace" "terraform-cloud" {
  lifecycle {
    prevent_destroy = true
  }
  name              = "terraform-cloud"
  description       = "Manages all Terraform Cloud organizations, workspaces, and variables."
  organization      = tfe_organization.zbmowrey-cloud-admin.name
  execution_mode    = "remote"
  auto_apply        = false
  terraform_version = var.terraform_version

  vcs_repo {
    branch             = "main"
    identifier         = "zbmowrey/terraform-cloud"
    oauth_token_id     = data.tfe_oauth_client.cloud-admin.oauth_token_id
    ingress_submodules = false
  }
}

# Cloud Admin - the Governance Accounts of Various Cloud Providers.

resource "tfe_workspace" "cloud-admin" {
  lifecycle {
    prevent_destroy = true
  }
  name              = "cloud-admin"
  description       = "Governance Configuration for Cloud Service Providers"
  organization      = tfe_organization.zbmowrey-cloud-admin.name
  execution_mode    = "local"
  auto_apply        = false
  terraform_version = var.terraform_version
}

# Version Control - Github/Gitlab Repository Configuration Management

resource "tfe_workspace" "version-control" {
  lifecycle {
    prevent_destroy = true
  }
  name              = "version-control"
  description       = "VCS Repository Management"
  organization      = tfe_organization.zbmowrey-cloud-admin.name
  execution_mode    = "local"
  auto_apply        = false
  terraform_version = var.terraform_version
}

# Get all workspaces in this Org.

data "tfe_workspace_ids" "cloud-admin-all" {
  depends_on   = [tfe_workspace.cloud-admin]
  organization = tfe_organization.zbmowrey-cloud-admin.name
  names        = ["*"]
}

# Every workspace in the Org gets a Slack configuration.

resource "tfe_notification_configuration" "cloud-admin-slack" {
  for_each         = data.tfe_workspace_ids.cloud-admin-all.ids
  destination_type = "slack"
  enabled          = true
  url              = var.terraform_slack_url
  name             = "Terraform Cloud"
  workspace_id     = each.value
  triggers         = local.notification_triggers
}