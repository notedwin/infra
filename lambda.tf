resource "aws_s3_bucket" "deployment-packages" {
  bucket        = "deployment-packages"
  acl           = "private"
  force_destroy = "true"
}
resource "aws_s3_bucket_object" "lambda_s3_bucket_object" {
  bucket = "${aws_s3_bucket.deployment-packages.arn}"
  key    = "${replace(var.lambda_name,"-","_")}.zip"
  source = var.dist
  etag   = "${filemd5("${var.dist}")}"
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.lambda_name}-role"
  managed_policy_arns = [ "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole", "arn:aws:iam::aws:policy/AWSLambda_FullAccess"]
  assume_role_policy = <<EOF
  {
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "lambda:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_lambda_function" "lambda" {
  s3_key           = "${replace(var.lambda_name,"-","_")}.zip"
  source_code_hash = "${filebase64sha256("${var.dist}")}"
  depends_on       = [aws_s3_bucket_object.lambda_s3_bucket_object]
  s3_bucket        = aws_s3_bucket.deployment-packages.arn
  function_name    = "${var.lambda_name}"
  role             = aws_iam_role.lambda_role.arn
  handler          = "${replace(var.lambda_name,"-","_")}.main"
  runtime          = "python3.7"
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory

  environment {
    variables = {
      # env vars
    }
  }
}
