locals {
  cloud-admin_org   = "zbmowrey"
  cloud-admin_app   = "cloud-admin"
  cloud-admin_email = "zbmowrey@gmail.com"
}

# This organization contains our state. It must not be destroyed.

resource "tfe_organization" "zbmowrey-cloud-admin" {
  lifecycle {
    prevent_destroy = true
  }
  email = local.cloud-admin_email
  name  = "zbmowrey-cloud-admin"
}

# Create one workspace for any environment defined in terraform.auto.tfvars.
# Get the VCS client ID for this workspace by editing, then pull from URL.

data "tfe_oauth_client" "cloud-admin" {
  oauth_client_id = var.oauth_clients.cloud-admin
}

# Create one workspace for any environment defined in terraform.auto.tfvars.

resource "tfe_workspace" "cloud-admin" {
  name         = "cloud-admin"
  organization = tfe_organization.zbmowrey-cloud-admin.name
  vcs_repo {
    identifier     = "zbmowrey/cloud-admin"
    oauth_token_id = data.tfe_oauth_client.cloud-admin.oauth_token_id
    branch         = "main"
  }
}

resource "tfe_notification_configuration" "cloud-admin-slack" {
  destination_type = "slack"
  enabled          = true
  url              = var.terraform_slack_url
  name             = "Terraform Cloud"
  workspace_id     = tfe_workspace.cloud-admin.id
  triggers = ["run:created", "run:needs_attention", "run:completed", "run:errored"]
}

# Access keys for the various cloud-admin environments.

resource "tfe_variable" "cloud-admin-access-keys" {
  category     = "env"
  key          = "AWS_ACCESS_KEY_ID"
  value        = var.aws_root_key
  workspace_id = tfe_workspace.cloud-admin.id
  sensitive    = true
}

# Secret keys for the various cloud-admin environments.

resource "tfe_variable" "cloud-admin-secret-keys" {
  category     = "env"
  key          = "AWS_SECRET_ACCESS_KEY"
  value        = var.aws_root_secret
  workspace_id = tfe_workspace.cloud-admin.id
  sensitive    = true
}

resource "tfe_variable" "cloud-admin-region" {
  category     = "terraform"
  key          = "region"
  value        = "us-east-2"
  workspace_id = tfe_workspace.cloud-admin.id
  sensitive    = false
}

resource "tfe_variable" "cloud-admin-email" {
  category     = "terraform"
  key          = "root_account_email"
  value        = "zb@zbmowrey.com"
  workspace_id = tfe_workspace.cloud-admin.id
  sensitive    = false
}

resource "tfe_variable" "cloud-admin-account-name" {
  category     = "terraform"
  key          = "root_account_name"
  value        = "zbmowrey76"
  workspace_id = tfe_workspace.cloud-admin.id
  sensitive    = false
}

resource "tfe_variable" "cloud-admin-domain" {
  category     = "terraform"
  key          = "account_email_domain"
  value        = "@zbmowrey.com"
  workspace_id = tfe_workspace.cloud-admin.id
  sensitive    = false
}
