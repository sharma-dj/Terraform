resource "aws_security_group" "my_sg" {
  name = "study-my_sg-sg"
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
    cidr_blocks = ["0.0.0.0/0","81.150.79.181/32"]
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

  tags = {
    Name = "Application : test instance sg"
    Desc = "This is Security Group for EC2 Server Instance"
  }
  
}
