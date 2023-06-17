provider "aws" {
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
    region = var.aws_region
}

resource "aws_key_pair" "terraform-demo" {
  key_name   = "terraform-key"
  public_key = file("terraform-key.pub")
}

resource "aws_instance" "ec2-instance" {
  ami             = var.amis[var.aws_region]
  instance_type   = var.instance_type
  vpc_security_group_ids = [aws_security_group.busybox.id]
  key_name        = aws_key_pair.terraform-demo.key_name
  user_data = data.template_file.client.rendered

  tags = {
		Name = "Terraform"
	}
}

data "template_file" "client" {
  template = file("wp.sh")

  vars = {
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
    region = var.aws_region
    siteurl = "wordpress.vincegironda.com"
    admin_username = "admin"
    admin_email = "dhananjay@nadsoftdev.com"
    admin_password = "nadsoft123"
    site_name = "Sanetris New Site"
  }
}

resource "aws_security_group" "busybox" {
  name = "study-busybox-sg"
  ingress {
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.https_port
    to_port     = var.https_port
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
      from_port = var.mysql_port
      to_port = var.mysql_port
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  
}

resource "aws_s3_bucket" "example" {
  bucket = "my-test-s3-tf-bucket"
  acl = "public-read"
  policy = file("policy.json")
  
  versioning {
    enabled = true
  }

  tags = {
    Name = "my-test-s3-terraform-bucket"
  }

}

resource "null_resource" "nullresource" {
    provisioner "file" {
        source      = "restore.sh"
        destination = "/tmp/restore.sh"

        connection {
            type        = "ssh"
            user        = "ubuntu"
            host = aws_instance.ec2-instance.public_ip
            private_key = file("terraform-key")
        }
    }

    provisioner "file" {
        source      = "backup.sh"
        destination = "/tmp/backup.sh"

        connection {
            type        = "ssh"
            user        = "ubuntu"
            host = aws_instance.ec2-instance.public_ip
            private_key = file("terraform-key")
        }
    }
}