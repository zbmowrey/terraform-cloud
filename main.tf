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
  token = var.terraform_token
}

# Locals here is probably more like "globals", but it's a list that won't change a lot.
# Github (afaik) doesn't support structured secrets (yet).

locals {
  notification_triggers = ["run:needs_attention", "run:planning", "run:completed", "run:errored"]
}

# Workspaces should be defined & managed in the relevant org-*.tf file.
# Secrets/variables should not be stored in Terraform Cloud or Serverless Framework.
# Secrets may be stored in Github. See the version-control repository for that.