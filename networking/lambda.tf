resource "aws_lambda_function" "test_lambda" {
  filename         = var.dist
  function_name    = "python_attack_map"
  role             = aws_iam_role.iam_for_lambda_tf.arn
  handler          = "index.handler"
  source_code_hash = filebase64sha256("${var.dist}")
  runtime          = "python3.8"
  memory_size      = var.lambda_memory
  timeout          = var.lambda_timeout
  #reserved_concurrent_executions = 0

  vpc_config {
    subnet_ids         = [aws_subnet.private-subnet.id, aws_subnet.public-subnet.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = { 
      REDIS_URL = "redis://${aws_elasticache_cluster.redis.cache_nodes.0.address}:${aws_elasticache_cluster.redis.cache_nodes.0.port}" 
      RUST_BACKTRACE = "1"
      }
  }

  tracing_config {
    mode = "Active"
  }

}

resource "aws_lambda_function" "rust_async_lambda" {
  function_name    = "rust-lambda"
  filename         = var.rust_dist
  source_code_hash = filebase64sha256("${var.rust_dist}")
  handler          = "index.handler"
  memory_size      = var.lambda_memory
  timeout          = "300"

  role = aws_iam_role.iam_for_lambda_tf.arn

  runtime = "provided.al2"

  vpc_config {
    subnet_ids         = [aws_subnet.private-subnet.id, aws_subnet.public-subnet.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      REDIS_URL = "redis://${aws_elasticache_cluster.redis.cache_nodes.0.address}:${aws_elasticache_cluster.redis.cache_nodes.0.port}"
      RUST_BACKTRACE = "full"
    }
  }

  tracing_config {
    mode = "Active"
  }
}

resource "aws_security_group" "lambda_sg" {
  name        = "lambda_sg"
  description = "Security group for lambda"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_iam_role" "iam_for_lambda_tf" {
  name = "iam_for_lambda_tf"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


# resource "aws_iam_role_policy_attachment" "test_lambda" {
#   role= aws_iam_role.iam_for_lambda_tf.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
# }

resource "aws_iam_role_policy_attachment" "vpc" {
  role       = aws_iam_role.iam_for_lambda_tf.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "full" {
  role       = aws_iam_role.iam_for_lambda_tf.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
}

# resource "aws_lambda_permission" "api_gw" {
#   statement_id  = "AllowExecutionFromAPIGateway"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.test_lambda.function_name
#   principal     = "apigateway.amazonaws.com"
#   source_arn    = "${aws_apigatewayv2_api.notedwin_main_apigw.execution_arn}/*/*"
# }


resource "aws_lambda_permission" "api_gw_rust" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rust_async_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.notedwin_main_apigw.execution_arn}/*/*"
}