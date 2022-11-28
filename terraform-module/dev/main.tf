terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region = var.aws_region
}

data "aws_availability_zones" "all" {}

resource "aws_key_pair" "terraform-my-demo" {
  key_name   = "terraform-my-key"
  public_key = file("terraform-key.pub")
}

module "my_ec2" {
  source = "../modules/ec2"
  security_group_id = module.ec2_sg.my_sg_id
  key_name = aws_key_pair.terraform-my-demo.key_name
}

module "ec2_sg" {
  source = "../modules/sg"
}
