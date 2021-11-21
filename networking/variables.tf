variable "CLOUDFLARE_API_TOKEN" {
  type = string
}
variable "CLOUDFLARE_EMAIL" {
  type = string
  default = "zamudio.e13@gmail.com"
}

variable "api_user_service_key" {
  type = string
}

variable "application" {
  default = "infra-edwin"
  type = string
}

variable "aws_region" {
  default = "us-east-2"
  type = string
}

variable "domain" {
  default = "notedwin.tech"
  type = string
}

variable "server_ip" {
  default = "73.75.61.15"
  type = string
}

