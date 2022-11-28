resource "aws_instance" "ec2-test-instance" {
  ami             = var.amis[var.aws_region]
  instance_type   = var.instance_type
  vpc_security_group_ids = [var.security_group_id]
  key_name = var.key_name
  
  tags = {
    Name = "Application : test instance"
    Desc = "This is an EC2 Server Instance"
  }
}
