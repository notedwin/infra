resource "aws_acm_certificate" "cert" {
  domain_name               = var.domain_name
  subject_alternative_names = ["aws.${var.domain_name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_apigatewayv2_domain_name" "notedwin_apigw_domain" {
  domain_name = var.domain_name
  regional_certificate_arn = aws_acm_certificate.cert.arn
}

resource "aws_apigatewayv2_api" "notedwin_main_apigw" {
  name        = "notedwin_main_apigw"
  protocol_type = "http"
}

resource "aws_apigatewayv2_stage" "notedwin_main_api" {
  api_id = aws_apigatewayv2_api.notedwin_main_apigw.id
  stage_name = "main"
  deployment_id = aws_apigatewayv2_deployment.notedwin_main_deployment.id
}

resource "aws_apigatewayv2_integration" "notedwin" {
  api_id = aws_apigatewayv2_api.notedwin_main_apigw.id
  integration_method = "ANY"
  integration_type = "AWS_PROXY"
  #integration_uri
  payload_format_version = 2.0
  timeout_milliseconds = 30000
  passthrough_behavior = WHEN_NO_MATCH
}

resource "aws_apigatewayv2_api_mapping" "aws-gateway" {
  api_id = aws_apigatewayv2_api.notedwin_main_apigw.id
  domain_name = var.domain_name
  stage = aws_apigatewayv2_stage.notedwin_main_api.stage_name
  
}

resource "aws_apigatewayv2_route" "default" {
  api_id = aws_apigatewayv2_api.notedwin_main_apigw.id
  route_key = "default"
  target = 
  
}



# ## create elasticache cluster
# # apigateway with custom domain name
# # also create a route53 record for the custom domain name
# # create a acm certificate for the custom domain name

# resource "aws_elasticache_cluster" "cluster" {
#   cluster_id              = "tf-acc-cluster-%d"
#   engine                  = "redis"
#   node_type               = "cache.m3.medium"
#   num_cache_nodes         = 1
#   port                    = 6379
#   security_group_names    = [aws_security_group.test.name]
#   subnet_group_name       = aws_elasticache_subnet_group.subnet_group.name
#   parameter_group_name    = aws_elasticache_parameter_group.parameter_group.name
#   apply_immediately       = true
#   auto_minor_version_upgrade = true
#   availability_zone       = aws_subnet.subnet.availability_zone
#   tags {
#     environment = "production"
#     Name        = "tf-acc-cluster-%d"
#   }
# }