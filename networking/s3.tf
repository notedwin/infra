# s3 bucket with Single page application
# cloudfront distribution

resource "aws_s3_bucket" "bucket" {
  bucket        = "attack-map-bucket"
  acl           = "public-read"
  force_destroy = true
}

resource "aws_s3_bucket_object" "object" {
  bucket = aws_s3_bucket.bucket.id
  key    = "index.html"
  content_type = "text/html"
  content = file("index.html")
}

resource "aws_cloudfront_distribution" "distribution" {
  # set price class to cheapest to ensure the distribution is cheaper
  price_class = "PriceClass_100"
  # alternate domain name
  aliases = [ "map.notedwin.tech" ]
  origin {
    domain_name = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_id   = "s3"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.OAI.cloudfront_access_identity_path
    }
  }
  origin {
    domain_name = replace(aws_apigatewayv2_api.notedwin_main_apigw.api_endpoint, "/^https?://([^/]*).*/", "$1")
    origin_id   = "apigw"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "/data"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "apigw"

    default_ttl = 0
    min_ttl     = 0
    max_ttl     = 0

    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cert-dns.arn
    ssl_support_method      = "sni-only"
  }
}

resource "aws_cloudfront_origin_access_identity" "OAI" {
}

resource "aws_s3_bucket_policy" "default" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.default.json
}

data "aws_iam_policy_document" "default" {
  statement {
    actions = ["s3:GetObject"]

    resources = ["${aws_s3_bucket.bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.OAI.iam_arn]
    }
  }
}

output "frontend_url" {
  value = aws_cloudfront_distribution.distribution.domain_name
}

resource "aws_acm_certificate" "cert-dns" {
  provider = aws.us-east-1
  domain_name = "map.notedwin.tech"
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "cloudflare_record" "acm" {
  for_each = {
    for dvo in aws_acm_certificate.cert-dns.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = data.cloudflare_zone.domain.id
  name            = each.value.name
  value          = each.value.record
  type            = each.value.type
  proxied = false
}


resource "aws_acm_certificate_validation" "cert" {
  provider = aws.us-east-1
  certificate_arn = aws_acm_certificate.cert-dns.arn
}






