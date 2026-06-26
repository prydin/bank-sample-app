# Frontend VirtualMachines (VM Operator). The frontend-bootstrap Secret and the
# frontend-lb VirtualMachineService they rely on are created elsewhere.
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
