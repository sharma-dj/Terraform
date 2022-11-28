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

variable "elb_port" {
  description = "The port the elb will be listening"
  type        = number
  default     = 80
}
