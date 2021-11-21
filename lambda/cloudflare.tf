data "cloudflare_zone" "domain" {
  name = var.domain
}

resource "cloudflare_record" "domain" {
  zone_id = data.cloudflare_zone.domain.id
  name    = var.domain
  value   = var.server_ip
  type    = "A"
  ttl = 1
  proxied = true
}

resource "cloudflare_record" "map" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "map"
  value   = var.server_ip
  type    = "A"
  ttl = 1
  proxied = true
}

resource "cloudflare_record" "restaurant" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "restaurant"
  value   = var.server_ip
  type    = "A"
  ttl = 1
  proxied = true
}

resource "cloudflare_record" "tutor" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "tutor"
  value   = var.server_ip
  type    = "A"
  ttl = 1
  proxied = true
}

resource "cloudflare_record" "www" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "www"
  value   = var.server_ip
  type    = "A"
  ttl = 1
  proxied = true
}

output "cloudflare_zone" {
  value = data.cloudflare_zone.domain.id
}

output "id_map" {
  value = cloudflare_record.map.id
}

