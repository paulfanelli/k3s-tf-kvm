variable "base_image_path" {
  description = "The path to the base image"
  type        = string
  default     = "https://download.fedoraproject.org/pub/fedora/linux/releases/43/Cloud/x86_64/images/Fedora-Cloud-Base-Generic-43-1.6.x86_64.qcow2"
}

#variable "ssh_public_keys" {
#  description = "The local SSH public keys"
#  type        = list(string)
#  default = [
    #    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC+Y6+H/LxwTxaqACvcy+GDL55C62CXjb2ZDBLj88GFz paul@localhost-live"
    #    file(pathexpand("~/.ssh/id_ed25519.pub"))
    #  ]
    #}

variable "ssh_public_key_file" {
  description = "The local SSH public key file"
  type        = string
  default = "~/.ssh/id_ed25519.pub"
}

output "foo" {
  value = var.ssh_public_key_file
}
