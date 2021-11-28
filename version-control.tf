resource "tfe_workspace" "version-control" {
  name                = "version-control"
  description         = "VCS Repository Management"
  organization        = tfe_organization.zbmowrey-cloud-admin.name
  vcs_repo {
    identifier     = "zbmowrey/version-control"
    oauth_token_id = data.tfe_oauth_client.cloud-admin.oauth_token_id
    branch         = "main"
  }
  auto_apply          = true
  speculative_enabled = true
}

resource "tfe_notification_configuration" "version-control" {
  destination_type = "slack"
  enabled          = true
  url              = var.terraform_slack_url
  name             = "Terraform Cloud"
  workspace_id     = tfe_workspace.version-control.id
  triggers         = local.notification_triggers
}

resource "tfe_variable" "aws_key_main" {
  sensitive = true
  category     = "terraform"
  key          = "aws_key_main"
  value        = var.aws_key_main
  workspace_id = tfe_workspace.version-control.id
}
resource "tfe_variable" "aws_secret_main" {
  sensitive = true
  category     = "terraform"
  key          = "aws_secret_main"
  value        = var.aws_secret_main
  workspace_id = tfe_workspace.version-control.id
}
resource "tfe_variable" "aws_key_staging" {
  sensitive = true
  category     = "terraform"
  key          = "aws_key_staging"
  value        = var.aws_key_staging
  workspace_id = tfe_workspace.version-control.id
}
resource "tfe_variable" "aws_secret_staging" {
  sensitive = true
  category     = "terraform"
  key          = "aws_secret_staging"
  value        = var.aws_secret_staging
  workspace_id = tfe_workspace.version-control.id
}
resource "tfe_variable" "aws_key_develop" {
  sensitive = true
  category     = "terraform"
  key          = "aws_key_develop"
  value        = var.aws_key_develop
  workspace_id = tfe_workspace.version-control.id
}
resource "tfe_variable" "aws_secret_develop" {
  sensitive = true
  category     = "terraform"
  key          = "aws_secret_develop"
  value        = var.aws_secret_develop
  workspace_id = tfe_workspace.version-control.id
}
resource "tfe_variable" "github_token" {
  sensitive = true
  category     = "terraform"
  key          = "github_token"
  value        = var.github_token
  workspace_id = tfe_workspace.version-control.id
}
resource "tfe_variable" "terraform_token" {
  sensitive = true
  category     = "terraform"
  key          = "terraform_token"
  value        = var.terraform_token
  workspace_id = tfe_workspace.version-control.id
}
resource "tfe_variable" "serverless_token" {
  sensitive = true
  category     = "terraform"
  key          = "serverless_token"
  value        = var.serverless_token
  workspace_id = tfe_workspace.version-control.id
}
resource "tfe_variable" "cf_distributions" {
  category     = "terraform"
  key          = "cf_distributions"
  value        = replace(jsonencode(var.cf_distributions), "/(\".*?\"):/", "$1 = ")
  hcl          = true
  workspace_id = tfe_workspace.version-control.id
}