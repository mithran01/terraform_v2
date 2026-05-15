ansible-playbook create-client.yml \
  -i inventory.ini \
  -e "client_name=mithran client_ip=10.0.0.2/32"