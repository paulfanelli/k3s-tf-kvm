# Define the local storage pool
resource "libvirt_pool" "fedora_pool" {
  name = "fedora_pool"
  type = "dir"
  path = "/var/lib/libvirt/images/terraform"
}

locals {
  vm_count = 3
}

# Download the base image
resource "libvirt_volume" "fedora_base" {
  count = local.vm_count
  name   = format("fedora_base_%d.qcow2", count.index)
  pool   = libvirt_pool.fedora_pool.name
  source = var.base_image_path
  format = "qcow2"
}

data "cloudinit_config" "x" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"

    content = yamlencode({
      users = [
        {
          name = "fedora"
          ssh_authorized_keys = [
            file(pathexpand(var.ssh_public_key_file))
          ]
          sudo  = "ALL=(ALL) NOPASSWD:ALL"
          shell = "/bin/bash"
        }
      ]
    })
  }
}

# Cloud-init configuration (for user/ssh keys)
resource "libvirt_cloudinit_disk" "commoninit" {
  count  = local.vm_count
  name = format("commoninit_%d.iso", count.index)
  # name = "commoninit.iso"
  pool = libvirt_pool.fedora_pool.name
  user_data      = data.cloudinit_config.x.rendered
  network_config = <<-EOT
  version: 2
  ethernets:
    eth0:
      dhcp4: true
  EOT
}

# Define the VM
resource "libvirt_domain" "fedora_vm" {
  count  = local.vm_count
  # name   = format("terraform-fedora%d", count.index)
  name   = count.index == 0 ? "leader" : format("follower%d", count.index)
  # name   = "terraform-fedora${count.index}"
  memory = "2048"
  vcpu   = 2

  network_interface {
    network_name   = "default"
    # addresses      = ["192.168.122.200"]
    addresses      = [cidrhost("192.168.122.0/24", 200 + count.index)]
    wait_for_lease = true # This forces Terraform to wait for the IP
  }

  disk {
    volume_id = libvirt_volume.fedora_base[count.index].id
  }

  cloudinit = libvirt_cloudinit_disk.commoninit[count.index].id

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

output "ip" {
  value = libvirt_domain.fedora_vm[*].network_interface[0].addresses[0]
}
