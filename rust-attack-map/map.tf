data "aws_iam_role" "iam_role" {
  name = "iam_for_lambda_tf"
}

variable "rust_dist" {
  default = "~/notedwin/projects/infrastructure/rust-attack-map/target/x86_64-unknown-linux-gnu/release/lambda.zip"
  type    = string
}

resource "aws_lambda_function" "rust_async_lambda" {
  function_name = "rust-lambda"
  filename      = var.rust_dist
  source_code_hash = filebase64sha256("${var.rust_dist}")
  handler       = "index.handler"

  role = data.aws_iam_role.iam_role.arn

  runtime = "provided.al2"

  environment {
    variables = {
      RUST_BACKTRACE = "1"
    }
  }

  tracing_config {
    mode = "Active"
  }
}