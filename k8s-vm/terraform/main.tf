locals {
  postgres_vm = [for d in split("\n---\n", file("${path.module}/../10-postgres-vm.yaml")) : yamldecode(d) if try(yamldecode(d).kind, "") == "VirtualMachine"][0]
  backend_vm  = [for d in split("\n---\n", file("${path.module}/../20-backend-vm.yaml")) : yamldecode(d) if try(yamldecode(d).kind, "") == "VirtualMachine"][0]
}

resource "kubernetes_manifest" "postgres" {
  manifest = merge(local.postgres_vm, { metadata = merge(local.postgres_vm.metadata, { namespace = var.namespace }) })
}

resource "kubernetes_manifest" "backend" {
  manifest = merge(local.backend_vm, { metadata = merge(local.backend_vm.metadata, { namespace = var.namespace }) })
}

resource "kubernetes_manifest" "frontend" {
  count = var.vm_count

  manifest = {
    apiVersion = "vmoperator.vmware.com/v1alpha5"
    kind       = "VirtualMachine"

    metadata = {
      name      = format("frontend-%02d", count.index + 1)
      namespace = var.namespace
      labels = {
        app = "frontend"
      }
    }

    spec = {
      # Adjust these to a class, image, and StorageClass that exist in your
      # Supervisor namespace -- see the README.
      className     = "best-effort-small"
      imageName     = "ubuntu"
      storageClass  = "vsan-default-storage-policy"
      powerState    = "PoweredOn"

      network = {
        hostName = format("frontend-%02d", count.index + 1)
      }

      bootstrap = {
        cloudInit = {
          rawCloudConfig = {
            name = "frontend-bootstrap"
            key  = "user-data"
          }
        }
      }
    }
  }
}
