variable "application" {
  default = "infra-edwin"
  type = string
}

variable "aws_region" {
  default = "us-east-1"
  type = string
}

variable "lambda_name" {
  type = string
}

variable "lambda_memory" {
  default = 1024
}

variable "lambda_timeout" {
  default = 900
}

variable "dist" {
  type = string
  default = "~/notedwin/projects/vega-punk/vega_punk/lambda-dist/vega_punk/vega_punk.zip"
}