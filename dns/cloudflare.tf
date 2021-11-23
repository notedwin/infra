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
