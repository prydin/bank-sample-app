terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.20"
    }

    vcfa = {
      source = "vmware/vcfa"
    }

  }
}

locals {
    # api_token = file("~/Desktop/vcfa_api_token.txt")
    api_token = "I3nbvkXq9m9gzcYRRk226Xr1N3J27cZn"
}


provider "vcfa" {
  url                  = var.vcfa_url
  allow_unverified_ssl = true
  org                  = var.org_name
  auth_type            = "api_token"
  api_token            = local.api_token
}

# Uses your current kubeconfig context. Point this at the Supervisor namespace
# (or pass --context) the same way `kubectl` is configured for deploy.sh.
provider "kubernetes" {
  config_path = "~/.kube/config"
}

