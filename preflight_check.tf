data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "subnet_us_east_1a" {
  id = "subnet-0b4c028473d106e9e"
}

data "aws_subnet" "subnet_us_east_1b" {
  id = "subnet-0dc53fd2b335c29f6"
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

data "aws_key_pair" "existing_key" {
  key_name = "demov1"
}
