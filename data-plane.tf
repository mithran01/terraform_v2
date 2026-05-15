resource "aws_instance" "data_plane" {
  count                       = 1
  ami                         = data.aws_ami.rocky_linux.id
  instance_type               = "t3.small"
  subnet_id                   = data.aws_subnet.subnet_us_east_1b.id
  key_name                    = aws_key_pair.demov2.key_name
  iam_instance_profile        = aws_iam_instance_profile.kubeadm_profile.name
  associate_public_ip_address = true
  vpc_security_group_ids      = ["sg-0a77e32b49bdfe70e"]

  tags = {
    Name       = "data-plane-${count.index}"
    Role       = "data-plane"
    Managed_by = "Terraform-user"
  }
}
