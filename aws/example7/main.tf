
locals {
  apigw_name                  = "${lower(var.app_name)}-${lower(var.app_environment)}-apigw1"
  function_name               = "${lower(var.app_name)}-${lower(var.app_environment)}-function1"
  function_handler            = "index.lambda_handler"
  function_runtime            = "python3.9"
  function_source_dir = "${path.module}/aws_lambda_functions/function1"
  function_zip_file   = "${path.module}/aws_lambda_functions/${local.function_name}.zip"
  function_timeout_in_seconds = 5
}


# HTTP API
resource "aws_apigatewayv2_api" "api" {
	name          = local.apigw_name
	protocol_type = "HTTP"
	target        = aws_lambda_function.function.arn
}

# resource "aws_apigatewayv2_route" "default_route" {
#   api_id            = aws_apigatewayv2_api.api.id
#   route_key         = "$default"
#   authorization_type = "AWS_IAM"

#   # modify the integration settings
#   target = aws_lambda_function.function.arn
# }

resource "aws_lambda_permission" "apigw" {
	action        = "lambda:InvokeFunction"
	function_name = aws_lambda_function.function.arn
	principal     = "apigateway.amazonaws.com"
	source_arn = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}


resource "aws_lambda_function" "function" {
  function_name = local.function_name
  handler       = "index.lambda_handler"
  runtime       = "python3.9"
  timeout       = 5

  filename         = local.function_zip_file
  source_code_hash = data.archive_file.function_zip.output_base64sha256

  role = aws_iam_role.function_role.arn

}

data "archive_file" "function_zip" {
  type        = "zip"
  source_dir = local.function_source_dir
  output_path = local.function_zip_file
}

resource "aws_iam_role" "function_role" {
  name = "${local.function_name}-role"

  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

output my_ip_url {
  value = aws_apigatewayv2_api.api.api_endpoint
}
