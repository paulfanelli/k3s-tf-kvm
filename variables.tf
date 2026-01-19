variable "ssh_public_key_path" {
  description = "The path to the local SSH public key file"
  type = string
  default = "~/.ssh/id_ed25519.pub"
}
