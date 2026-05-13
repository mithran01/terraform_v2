#!/bin/bash

## Configuration variables ##
pem_key_path="/home/ec2-user/demov2.pem"
control_plane_ips="/home/ec2-user/control-plane-ips.txt"
data_plane_ips="/home/ec2-user/data-plane-ips.txt"
wireguard_ips="/home/ec2-user/wireguard-ips.txt"

### step 1: update system
sudo dnf update -y

### step 2:Install python2 and pip
echo "[+] updating system packages"
sudo dnf install -y python3 python3-pip

### step 3: Install ansible
echo "[+] Installing ansible on controller node"
sudo pip3 install ansible

### step 4: create ansible directory
echo "[+] Creating /etc/ansible directory if not exist"
sudo mkdir -p /etc/ansible
sudo touch /etc/ansible/hosts
sudo touch /etc/ansible/ansible.cfg


### step 6: generate ssh key pair (if not exist)
if [ ! -f ~/.ssh/id_rsa ];then
    echo "[+] generating ssh key pair . . ."
    ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa -q -N ""
else
    echo "[+] key pair already exist"
fi

### step 7: copy ssh public key to managed nodes
echo "[+] copying ssh key to managed node (control-plane)"

while read -r ip || [ -n "$ip" ];do
  [ -z "$ip" ] && continue
    ssh -n -o StrictHostKeyChecking=no -i "$pem_key_path" ec2-user@"$ip" "mkdir -p ~/.ssh && chmod 700 ~/.ssh && echo $(cat ~/.ssh/id_rsa.pub) >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
done < $control_plane_ips

### step 8: copy ssh public key to managed nodes
echo "[+] copying ssh key to managed node (data-plane)"

while read -r ip || [ -n "$ip" ];do
  [ -z "$ip" ] && continue
    ssh -n -o StrictHostKeyChecking=no -i "$pem_key_path" ec2-user@"$ip" "mkdir -p ~/.ssh && chmod 700 ~/.ssh && echo $(cat ~/.ssh/id_rsa.pub) >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
done < $data_plane_ips

### step 8.1: copy ssh public key to managed nodes
echo "[+] copying ssh key to managed node (data-plane)"

while read -r ip || [ -n "$ip" ];do
  [ -z "$ip" ] && continue
    ssh -n -o StrictHostKeyChecking=no -i "$pem_key_path" ec2-user@"$ip" "mkdir -p ~/.ssh && chmod 700 ~/.ssh && echo $(cat ~/.ssh/id_rsa.pub) >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
done < $wireguard_ips

### step 9: configure ansible inventory 
echo "[+] Writing inventory to /etc/ansible/hosts"
echo "[+] Writing inventory dynamically"

sudo tee /etc/ansible/hosts > /dev/null <<EOF
[controlplane]
$(cat "$control_plane_ips")

[dataplane]
$(cat "$data_plane_ips")

[wireguard]
$(cat "$wireguard_ips")


[all:vars]
ansible_user=ec2-user
ansible_python_interpreter=/usr/bin/python3
EOF

### step 10: configure ansible.cfg
echo "[+] Writing basic ansible configuration ..."
sudo bash -c 'cat > /etc/ansible/ansible.cfg' << EOF
[defaults]
inventory = /etc/ansible/hosts
host_key_checking = False
remote_user = ec2-user
deprecation_warning = False
EOF

### step 11: validate connection
echo "[+] validating ansible connection to all nodes"
if ansible all -m ping;then
    rm -rf $pem_key_path
    echo "[removed]: $pem_key_path key file"
else
    echo -e "\e[31m[FAILED]: ANSIBLE CONFIGURATION FAILED"
    exit 1
fi

echo -e "\e[32m[SUCCESS]: ansible controller and worker node are configured succesfully\e[0m"


