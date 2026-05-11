terraform {
  backend "s3" {
    bucket = "mithran-tf-state"
    key    = "ansible-server/terraform.tfstate"
    region = "us-east-1"
  }
}
