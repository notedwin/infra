data "cloudflare_zone" "domain" {
  name = var.domain
}

resource "cloudflare_record" "domain" {
  zone_id = data.cloudflare_zone.domain.id
  name    = var.domain
  value   = var.server_ip
  type    = "A"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "map" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "map"
  value   = var.server_ip
  type    = "A"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "restaurant" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "restaurant"
  value   = var.server_ip
  type    = "A"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "tutor" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "tutor"
  value   = var.server_ip
  type    = "A"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "www" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "www"
  value   = var.server_ip
  type    = "A"
  ttl     = 1
  proxied = true
}

resource "tls_private_key" "pk" {
  algorithm = "RSA"
}

resource "tls_cert_request" "csr" {
  key_algorithm   = tls_private_key.pk.algorithm
  private_key_pem = tls_private_key.pk.private_key_pem


  subject {
    common_name  = var.domain
    organization = "Cloudflare"
  }
}


resource "cloudflare_origin_ca_certificate" "origin_cert" {
  csr                = tls_cert_request.csr.cert_request_pem
  hostnames          = [var.domain, "*.${var.domain}"]
  request_type       = "origin-rsa"
  requested_validity = 7
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


output "cloudflare_zone" {
  value = data.cloudflare_zone.domain.id
}

