variable "base_image_path" {
  description = "The path to the base image"
  type = string
  default = "https://download.fedoraproject.org/pub/fedora/linux/releases/43/Cloud/x86_64/images/Fedora-Cloud-Base-Generic-43-1.6.x86_64.qcow2"
}

variable "ssh_public_key_path" {
  description = "The path to the local SSH public key file"
  type = string
  default = "~/.ssh/id_ed25519.pub"
}
