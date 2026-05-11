resource "aws_instance" "control_plane" {
  count                       = 1
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = data.aws_subnet.subnet_us_east_1a.id
  key_name                    = aws_key_pair.demov2.key_name
  associate_public_ip_address = true
  security_groups             = ["sg-0a77e32b49bdfe70e"]



  tags = {
    Name       = "control-plane-${count.index}"
    Role       = "control-plane"
    Managed_by = "Terraform-user"
  }
}
