terraform {
  required_version = ">= 1.3"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20"
    }
  }
}

# Uses your current kubeconfig context. Point this at the Supervisor namespace
# (or pass --context) the same way `kubectl` is configured for deploy.sh.
provider "kubernetes" {
  config_path = "~/.kube/config"
}
