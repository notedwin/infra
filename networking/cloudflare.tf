data "cloudflare_zone" "domain" {
  name = var.domain
}

resource "cloudflare_record" "domain" {
  for_each = toset(var.subdomains)
  zone_id  = data.cloudflare_zone.domain.id
  name     = each.value
  value    = var.server_ip
  type     = "A"
  ttl      = 1
  proxied  = true
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


