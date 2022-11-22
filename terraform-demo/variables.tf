variable "aws_access_key" {
  default = ""
}
variable "aws_secret_key" {
  default = ""
}
variable "aws_region" {
  description = "EC2 Region for the VPC"
  default = "us-east-1"
}
variable "amis" {
  description = "AMIs by region"
  type = map
  default = {
    "us-east-1" = "ami-04505e74c0741db8d"
  }
}
variable "server_port" {
  description = "The port the web server will be listening"
  type        = number
  default     = 8080
}

variable "http_port" {
  description = "The port the web server will be listening"
  type        = number
  default     = 80
}

variable "https_port" {
  description = "The port the web server will be listening"
  type        = number
  default     = 443
}

variable "mysql_port" {
  description = "The port the web server will be listening"
  type        = number
  default     = 3306
}

variable "ssh_port" {
  description = "The port for ssh connection"
  type        = number
  default     = 22
}

variable "instance_type" {
  description = "The type of EC2 Instances to run (e.g. t2.micro)"
  type        = string
  default     = "t2.micro"
}

variable "tag_name" {
  description = "Comman Tag Name"
  type        = string
  default     = "demo_ec2"
}
