
resource "aws_instance" "Ansible_Server_Master" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = data.aws_subnet.subnet_us_east_1a.id
  key_name                    = data.aws_key_pair.existing_key.key_name
  associate_public_ip_address = true
  security_groups             = ["sg-0a77e32b49bdfe70e"]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = var.ansible_master_private_key
    host        = aws_instance.Ansible_Server_Master.public_ip
  }


  provisioner "file" {
    source      = "demov2.pem"
    destination = "/home/ec2-user/demov2.pem"
  }

  provisioner "file" {
    source      = "ansible.sh"
    destination = "/home/ec2-user/ansible.sh" # ...to the EC2 master node
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

output "control_plane_ips" {
  value = aws_instance.control_plane[*].private_ip
}

output "data_plane_ips" {
  value = aws_instance.data_plane[*].private_ip
}

output "wireguard_server_ip" {
  value = aws_instance.wireguardVPN[*].private_ip
}

resource "local_file" "control_plane_ips" {
  content  = join("\n", aws_instance.control_plane[*].private_ip)
  filename = "control-plane-ips.txt"
}

resource "local_file" "data_plane_ips" {
  content  = join("\n", aws_instance.data_plane[*].private_ip)
  filename = "data-plane-ips.txt"
}

resource "local_file" "wireguard_ips" {
  content  = join("\n", aws_instance.wireguardVPN[*].private_ip)
  filename = "wireguard-ips.txt"
}

resource "null_resource" "copy_ips" {
  provisioner "file" {
    source      = "control-plane-ips.txt"
    destination = "/home/ec2-user/control-plane-ips.txt"
  }

  provisioner "file" {
    source      = "data-plane-ips.txt"
    destination = "/home/ec2-user/data-plane-ips.txt"
  }

  provisioner "file" {
    source      = "wireguard-ips.txt"
    destination = "/home/ec2-user/wireguard-ips.txt"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = var.ansible_master_private_key
    host        = aws_instance.Ansible_Server_Master.public_ip
  }

  depends_on = [
    aws_instance.Ansible_Server_Master,
    local_file.control_plane_ips,
    local_file.data_plane_ips
  ]
}


resource "null_resource" "run_ansible_script" {

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ec2-user/ansible.sh",
      "/home/ec2-user/ansible.sh"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = var.ansible_master_private_key
    host        = aws_instance.Ansible_Server_Master.public_ip
  }

  depends_on = [
    aws_instance.Ansible_Server_Master,
    aws_instance.control_plane,
    aws_instance.data_plane,
    aws_instance.wireguardVPN,
    null_resource.copy_ips
  ]
}
