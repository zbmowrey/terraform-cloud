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

provider "tfe" {
  token = "HmjeiIqsEghTNQ.atlasv1.Bm8zDKVxTmO4qdAA3sCAewuuIbFu56VQXD6chgsGijBxhJnHY3jox0fGBXIOH4g7gR4"
}

resource "tfe_workspace" "terraform-cloud" {
  name         = "terraform-cloud"
  organization = tfe_organization.zbmowrey-cloud-admin.name
  vcs_repo {
    identifier     = "zbmowrey/terraform-cloud"
    oauth_token_id = data.tfe_oauth_client.cloud-admin.oauth_token_id
    branch         = "main"
  }
}

resource "tfe_notification_configuration" "terraform-cloud" {
  destination_type = "slack"
  enabled          = true
  url              = var.terraform_slack_url
  name             = "Terraform Cloud"
  workspace_id     = tfe_workspace.terraform-cloud.id
  triggers = ["run:created", "run:needs_attention", "run:completed", "run:errored"]
}