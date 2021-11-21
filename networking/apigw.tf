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
  api_id = aws_apigatewayv2_api.notedwin_main_apigw.id
  # set integration type for lambda
  integration_type = "AWS_PROXY"

  connection_type        = "INTERNET"
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.test_lambda.invoke_arn
  payload_format_version = "2.0"
  timeout_milliseconds   = "30000"
  passthrough_behavior   = "WHEN_NO_MATCH"
}

resource "aws_apigatewayv2_api_mapping" "aws_gateway" {
  api_id      = aws_apigatewayv2_api.notedwin_main_apigw.id
  domain_name = aws_apigatewayv2_domain_name.notedwin_apigw_domain.id
  stage       = aws_apigatewayv2_stage.notedwin_main_api.id
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.notedwin_main_apigw.execution_arn}/*/*"
}
