
resource "aws_instance" "Ansible_Server_Master" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = data.aws_subnet.subnet_us_east_1a
  key_name                    = data.aws_key_pair.existing_key
  associate_public_ip_address = true
  security_groups             = ["sg-0a77e32b49bdfe70e"]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("C:/Users/imith/Desktop/terraform/practise/demov2") # Local private key for SSH access
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "C:/Users/imith/Desktop/terraform/practise/demov2" # Copy the local private key...
    destination = "/home/ec2-user/demov2.pem"                        # ...to the EC2 master node
  }

  provisioner "file" {
    source      = "C:/Users/imith/Desktop/terraform/practise/demov1/ansible.sh" # Copy the local private key...
    destination = "/home/ec2-user/ansible.sh"                                   # ...to the EC2 master node
  }

  provisioner "file" {
    source      = "C:/Users/imith/Desktop/terraform/practise/demov1/ansible-deployment/finexo-html.zip" # Copy the website folder...
    destination = "/home/ec2-user/finexo-html.zip"                                                      # ...to the EC2 master node
  }

  provisioner "file" {
    source      = "C:/Users/imith/Desktop/terraform/practise/demov1/ansible-deployment/deploy-website.yaml" # Copy the ansible yaml file...
    destination = "/home/ec2-user/deploy-website.yaml"                                                      # ...to the EC2 master node
  }

  provisioner "file" {
    source      = "C:/Users/imith/Desktop/terraform/practise/demov1/ansible-deployment/grafana-install.yaml" # Copy the ansible yaml file...
    destination = "/home/ec2-user/grafana-install.yaml"                                                      # ...to the EC2 master node
  }

  # Optional: Fix permissions for the copied key on the remote host
  provisioner "remote-exec" {
    inline = ["chmod 400 /home/ec2-user/demov2.pem"]
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ec2-user/ansible.sh",
      "chown ec2-user:ec2-user /home/ec2-user/ansible.sh"
    ]
  }

  tags = {
    Name       = "Ansible-Server"
    Managed_by = "Terraform-user"
  }
}
