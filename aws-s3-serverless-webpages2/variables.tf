/*
variable "aws_access_key" {
  description = ""
  default = ""
}

variable "aws_secret_key" {
  description = ""
  default = ""
}
*/

variable "aws_access_key" {
  default = ""
}
variable "aws_secret_key" {
  default = ""
}

variable "business_name" {
  description = ""
  default = "kts"
}

variable "product_name" {
  description = ""
  default = "mts"
}

variable "affiliate_name" {
  description = ""
  default = "kts"
}

variable "page" {
  description = ""
  default = "landing_page"
}

variable "s3_bucket_name" {
  description = "S3 Bucket Name"
  default = "bucketname2342342349900008"
}
