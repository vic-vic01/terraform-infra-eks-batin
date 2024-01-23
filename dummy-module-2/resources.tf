resource "null_resource" "example2" {
  provisioner "local-exec" {
    command = "echo ${local.message}"
  }
}


resource "aws_security_group" "allow_tls" {
  name        = "allow_tls_v2"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = "vpc-4dcc6630"

  tags = {
    Name = "allow_tls_v2"
  }
}

