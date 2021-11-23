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
  token = var.access_keys["tf_cloud"]
}
