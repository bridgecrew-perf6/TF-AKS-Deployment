resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_file" "private_key" {
  #count    = var.public_ssh_key == "" ? 1 : 0
  content  = tls_private_key.ssh.private_key_pem
  filename = "./ssh-key/private_ssh_key"
}

resource "local_file" "id_rsa_pub" {
  #count    = var.public_ssh_key == "" ? 1 : 0
  content  = tls_private_key.ssh.public_key_openssh
  filename = "./ssh-key/id_rsa.pub"
}

output "public_ssh_key" {
  # Only output a generated ssh public key
  value = var.public_ssh_key != "" ? "" : tls_private_key.ssh.public_key_openssh
}

variable "public_ssh_key" {
  description = "An ssh key set in the main variables of the terraform-azurerm-aks module"
  default     = ""
}
