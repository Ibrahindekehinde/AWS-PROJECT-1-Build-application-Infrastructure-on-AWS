# Create a private key
resource "tls_private_key" "utc1key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Register the public key with AWS
resource "aws_key_pair" "utc1key" {
  key_name   = "utc1key"
  public_key = tls_private_key.utc1key.public_key_openssh

  tags = {
    Name = "utc1key"
  }
}

# Save the private key as a .pem file
resource "local_sensitive_file" "utc_pem" {
  content         = tls_private_key.utc1key.private_key_pem
  filename        = "utc1key.pem"
  file_permission = "0600"
}

