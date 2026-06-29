  # Backend and Postgres are not coded in HCL. Instead we load the canonical
# Kubernetes manifests that live in the parent directory (the same files
# deploy.sh applies) and instantiate every document they contain.
#
# $NS and $DNS_VIP are only referenced in 05-secrets.yaml, which we assume is
# already loaded, so no substitution is needed here -- we just split the
# multi-document YAML and create one kubernetes_manifest per document.
locals {
  # Manifest files to load, relative to this module.
  vm_manifest_files = [
    "${path.module}/../10-postgres-vm.yaml",
    "${path.module}/../20-backend-vm.yaml",
  ]

  # Decode every YAML document in the manifest files.
  vm_manifest_documents = flatten([
    for f in local.vm_manifest_files : [
      for doc in split("\n---\n", file(f)) :
      yamldecode(doc)
      if trimspace(doc) != ""
    ]
  ])
}

resource "kubernetes_manifest" "backend_postgres" {
  for_each = {
    for doc in local.vm_manifest_documents :
    "${doc.kind}/${doc.metadata.name}" => doc
  }

  # The manifests don't hard-code a namespace (deploy.sh passes `kubectl -n`),
  # so inject it the same way the frontend resource below does.
  manifest = merge(each.value, {
    metadata = merge(each.value.metadata, {
      namespace = var.namespace
    })
  })
}

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
