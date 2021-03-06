data "cloudflare_zone" "domain" {
  name = var.domain
}

resource "cloudflare_record" "domain" {
  zone_id  = data.cloudflare_zone.domain.id
  name     = "@"
  value    = var.server_ip
  type     = "A"
  ttl      = 1
  proxied  = true
}

//redirect all subdomains except map
resource "cloudflare_record" "redirect" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "*"
  type    = "CNAME"
  value   = "${var.domain}"
  ttl     = 1
}

# resource "cloudflare_page_rule" "redirect" {
#   zone_id = data.cloudflare_zone.domain.id
#   target = "*.${var.domain}/*"
#   priority = 2
#   status = "active"
#   actions {
#     forwarding_url {
#       url = "https://${var.domain}"
#       status_code = "302"
#     }
#   }
# }

//redirect all subdomains except map



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

# create CNAME record for cloudfront
resource "cloudflare_record" "cname" {
  zone_id  = data.cloudflare_zone.domain.id
  name     = "map.${var.domain}"
  value    = aws_cloudfront_distribution.distribution.domain_name
  type     = "CNAME"
  ttl      = 1
  proxied  = true
}

resource "cloudflare_record" "site_cname" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "aws.${var.domain}"
  value   = trim(aws_apigatewayv2_api.notedwin_main_apigw.api_endpoint, "https://")
  type    = "CNAME"
  ttl     = 1
  proxied = true
}