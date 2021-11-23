resource "aws_apigatewayv2_api" "notedwin_main_apigw" {
  name          = "notedwin_apigw"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_domain_name" "notedwin_apigw_domain" {
  domain_name = "aws.${var.domain}"

  domain_name_configuration {
    certificate_arn = aws_acm_certificate.cert.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_stage" "notedwin_main_api" {
  api_id      = aws_apigatewayv2_api.notedwin_main_apigw.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_route" "default" {
  api_id    = aws_apigatewayv2_api.notedwin_main_apigw.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.notedwin.id}"
}


resource "aws_apigatewayv2_integration" "notedwin" {
  api_id                 = aws_apigatewayv2_api.notedwin_main_apigw.id
  integration_type       = "AWS_PROXY"
  connection_type        = "INTERNET"
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.test_lambda.invoke_arn
  payload_format_version = "2.0"
  timeout_milliseconds   = "30000"
  passthrough_behavior   = "WHEN_NO_MATCH"
}

resource "aws_apigatewayv2_api_mapping" "aws_gateway" {
  api_id          = aws_apigatewayv2_api.notedwin_main_apigw.id
  domain_name     = aws_apigatewayv2_domain_name.notedwin_apigw_domain.id
  stage           = aws_apigatewayv2_stage.notedwin_main_api.id
  api_mapping_key = "test"
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.notedwin_main_apigw.execution_arn}/*/*"
}

resource "cloudflare_record" "site_cname" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "aws.${var.domain}"
  value   = trim(aws_apigatewayv2_api.notedwin_main_apigw.api_endpoint, "https://")
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

resource "aws_acm_certificate" "cert" {
  private_key      = tls_private_key.pk.private_key_pem
  certificate_body = cloudflare_origin_ca_certificate.origin_cert.certificate
  // I would normally feel really bad about this, but it's a public certificate chain anyway. 
  certificate_chain = <<EOF
-----BEGIN CERTIFICATE-----
MIIEADCCAuigAwIBAgIID+rOSdTGfGcwDQYJKoZIhvcNAQELBQAwgYsxCzAJBgNV
BAYTAlVTMRkwFwYDVQQKExBDbG91ZEZsYXJlLCBJbmMuMTQwMgYDVQQLEytDbG91
ZEZsYXJlIE9yaWdpbiBTU0wgQ2VydGlmaWNhdGUgQXV0aG9yaXR5MRYwFAYDVQQH
Ew1TYW4gRnJhbmNpc2NvMRMwEQYDVQQIEwpDYWxpZm9ybmlhMB4XDTE5MDgyMzIx
MDgwMFoXDTI5MDgxNTE3MDAwMFowgYsxCzAJBgNVBAYTAlVTMRkwFwYDVQQKExBD
bG91ZEZsYXJlLCBJbmMuMTQwMgYDVQQLEytDbG91ZEZsYXJlIE9yaWdpbiBTU0wg
Q2VydGlmaWNhdGUgQXV0aG9yaXR5MRYwFAYDVQQHEw1TYW4gRnJhbmNpc2NvMRMw
EQYDVQQIEwpDYWxpZm9ybmlhMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC
AQEAwEiVZ/UoQpHmFsHvk5isBxRehukP8DG9JhFev3WZtG76WoTthvLJFRKFCHXm
V6Z5/66Z4S09mgsUuFwvJzMnE6Ej6yIsYNCb9r9QORa8BdhrkNn6kdTly3mdnykb
OomnwbUfLlExVgNdlP0XoRoeMwbQ4598foiHblO2B/LKuNfJzAMfS7oZe34b+vLB
yrP/1bgCSLdc1AxQc1AC0EsQQhgcyTJNgnG4va1c7ogPlwKyhbDyZ4e59N5lbYPJ
SmXI/cAe3jXj1FBLJZkwnoDKe0v13xeF+nF32smSH0qB7aJX2tBMW4TWtFPmzs5I
lwrFSySWAdwYdgxw180yKU0dvwIDAQABo2YwZDAOBgNVHQ8BAf8EBAMCAQYwEgYD
VR0TAQH/BAgwBgEB/wIBAjAdBgNVHQ4EFgQUJOhTV118NECHqeuU27rhFnj8KaQw
HwYDVR0jBBgwFoAUJOhTV118NECHqeuU27rhFnj8KaQwDQYJKoZIhvcNAQELBQAD
ggEBAHwOf9Ur1l0Ar5vFE6PNrZWrDfQIMyEfdgSKofCdTckbqXNTiXdgbHs+TWoQ
wAB0pfJDAHJDXOTCWRyTeXOseeOi5Btj5CnEuw3P0oXqdqevM1/+uWp0CM35zgZ8
VD4aITxity0djzE6Qnx3Syzz+ZkoBgTnNum7d9A66/V636x4vTeqbZFBr9erJzgz
hhurjcoacvRNhnjtDRM0dPeiCJ50CP3wEYuvUzDHUaowOsnLCjQIkWbR7Ni6KEIk
MOz2U0OBSif3FTkhCgZWQKOOLo1P42jHC3ssUZAtVNXrCk3fw9/E15k8NPkBazZ6
0iykLhH1trywrKRMVw67F44IE8Y=
-----END CERTIFICATE-----
EOF
}

# security group to connect to elasticache
resource "aws_security_group" "main-sg" {
  name        = "main-vpc"
  description = "main-vpc"
  vpc_id      = aws_vpc.main.id

  # allow ingress from anywhere
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  # allow egress to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }
}

# create vpc for resources
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}
