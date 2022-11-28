variable "aws_region" {
  description = "EC2 Region for the VPC"
  default = "us-east-2"
}
variable "amis" {
  description = "AMIs by region"
  type = map
  default = {
    "us-east-2" = "ami-0a63f96e85105c6d3"
  }
}
variable "instance_type" {
  description = "The type of EC2 Instances to run (e.g. t2.micro)"
  type        = string
  default     = "t2.micro"
}
variable "security_group_id" {}
variable "key_name" {}
