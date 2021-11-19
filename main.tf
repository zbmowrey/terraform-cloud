terraform {
  required_providers {
    tfe = {
      version = "~> 0.26.0"
    }
  }
  backend "remote" {
    organization = "zbmowrey"

    workspaces {
      name = "tfc-admin"
    }
  }
}

provider "tfe" {
  token = var.access_keys["tf_cloud"]
}

