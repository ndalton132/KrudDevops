resource "random_pet" "ssh_key_name" {
  prefix    = "ssh"
  separator = ""
}

# Generate an SSH key pair using TLS provider
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Store the public key in Azure (optional, for reference)
resource "azurerm_ssh_public_key" "main" {
  name                = random_pet.ssh_key_name.id
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  public_key          = tls_private_key.ssh.public_key_openssh
}

# Output the public key
output "key_data" {
  value = tls_private_key.ssh.public_key_openssh
}

# Output the private key (keep this secure!)
output "private_key_pem" {
  value     = tls_private_key.ssh.private_key_pem
  sensitive = true
}