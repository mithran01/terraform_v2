resource "aws_instance" "data_plane" {
  count                       = 0
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = data.aws_subnet.subnet_us_east_1b.id
  key_name                    = aws_key_pair.demov2.key_name
  associate_public_ip_address = false
  vpc_security_group_ids      = ["sg-0a77e32b49bdfe70e"]

  tags = {
    Name       = "data-plane-${count.index}"
    Role       = "data-plane"
    Managed_by = "Terraform-user"
  }
}
