provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region = var.aws_region
}

data "aws_availability_zones" "all" {}

resource "aws_key_pair" "terraform-demo" {
  key_name   = "terraform-key"
  public_key = file("terraform-key.pub")
}

resource "aws_instance" "sample-instance" {
  ami             = var.amis[var.aws_region]
  instance_type   = var.instance_type
  vpc_security_group_ids = [aws_security_group.demosg.id]
  key_name        = aws_key_pair.terraform-demo.key_name
  user_data       = file("user_data.sh")
  tags = {
		Name = "Terraform"
		Batch = "5AM"
	}
}

resource "aws_security_group" "demosg" {
  name = "study-demosg-sg"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress { # MySQL
      from_port = 3306
      to_port = 3306
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  
}