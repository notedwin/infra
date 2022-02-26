variable "CLOUDFLARE_API_TOKEN" {
  type = string
}
variable "CLOUDFLARE_EMAIL" {
  type    = string
  default = "zamudio.e13@gmail.com"
}

variable "api_user_service_key" {
  type = string
}

variable "lambda_memory" {
  default = 1024
}

variable "lambda_timeout" {
  default = 300
}

variable "application" {
  default = "infra-edwin"
  type    = string
}

variable "aws_region" {
  default = "us-east-2"
  type    = string
}

variable "domain" {
  default = "notedwin.tech"
  type    = string
}

variable "subdomains" {
  default = ["www", "tutor", "restaurant", "notedwin.tech", "jenkins"]
  type    = list(any)
}

variable "server_ip" {
  default = "76.76.21.21"
  type    = string
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  default = "10.0.0.0/24"
}

variable "private_subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "dist" {
  default = "~/notedwin/projects/infrastructure/attack_map/lambda-dist/attack_map/attack_map.zip"
  type    = string
}

variable "rust_dist" {
  default = "~/notedwin/projects/infrastructure/rust-attack-map/target/x86_64-unknown-linux-gnu/release/lambda.zip"
  type    = string
}

variable "html_file" {
  default = "~/notedwin/projects/infrastructure/attack_map/index.html"
  type    = string
}

variable "nat_ami" {
  default = "ami-0f07f5dc8c79ceb1e"
  type = string
}