terraform {
  required_providers {
    humanitec = {
      source  = "humanitec/humanitec"
      version = "~> 1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  required_version = ">= 1.3.0"
}

provider "humanitec" {
  org_id = var.humanitec_org
}


provider "helm" {
  kubernetes {
    config_path = var.kubeconfig
  }
}
