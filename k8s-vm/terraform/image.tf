
locals {
  region_name = var.region_name
}


data "vcfa_org" "acme" {
  name = var.org_name
}

data "vcfa_region" "region" {
  name = local.region_name
}

data "vcfa_storage_class" "sc" {
  region_id = data.vcfa_region.region.id
  name      = "vSAN Default Storage Policy"
}

resource "vcfa_content_library" "cl" {
  org_id      = data.vcfa_org.acme.id
  name        = "Bank App Demo-test"
  description = "Content library for the bank app demo"
  storage_class_ids = [
    data.vcfa_storage_class.sc.id
  ]
}

resource "null_resource" "ova_download" {
  provisioner "local-exec" {
    command = <<EOT
      if [ ! -f "${path.module}/ubuntu.ova" ]; then
        echo "Downloading OVA..."
        curl -L -sS -o "${path.module}/ubuntu.ova" https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.ova
      else
        echo "File already exists. Skipping."
      fi
    EOT
    interpreter = ["bash", "-c"]
  }

  lifecycle {
    ignore_changes = all
  }
}

resource "vcfa_content_library_item" "ova" {
  name               = "ubuntu"
  description        = "simple ubuntu image"
  content_library_id = vcfa_content_library.cl.id
  file_paths         = ["${path.module}/ubuntu.ova"]
  depends_on = [null_resource.ova_download]
}

