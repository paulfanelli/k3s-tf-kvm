terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.7.1"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

# Define the local storage pool
resource "libvirt_pool" "fedora_pool" {
  name = "fedora_pool"
  type = "dir"
  path = "/var/lib/libvirt/images/terraform"
}

# Download the base image
resource "libvirt_volume" "fedora_base" {
  name   = "fedora-base.qcow2"
  pool   = libvirt_pool.fedora_pool.name
  source = "download.fedoraproject.org"
  format = "qcow2"
}

# Cloud-init configuration (for user/ssh keys)
resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "commoninit.iso"
  pool           = libvirt_pool.fedora_pool.name
  user_data      = data.template_file.user_data.rendered
  network_config = data.template_file.network_config.rendered
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
}

data "template_file" "network_config" {
  template = file("${path.module}/network_config.cfg")
}

# Define the VM
resource "libvirt_domain" "fedora_vm" {
  name   = "terraform-fedora"
  memory = "2048"
  vcpu   = 2

  network_interface {
    network_name = "default"
  }

  disk {
    volume_id = libvirt_volume.fedora_base.id
  }

  cloudinit = libvirt_cloudinit_disk.commoninit.id

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
  value = libvirt_domain.fedora_vm.network_interface[0].addresses[0]
}
