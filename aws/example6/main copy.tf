
locals {
  function_name               = "${lower(var.app_name)}-${lower(var.app_environment)}-function1"
  function_handler            = "index.lambda_handler"
  function_runtime            = "python3.9"
  function_source_dir = "${path.module}/aws_lambda_functions/function1"
  function_zip_file   = "${path.module}/aws_lambda_functions/${local.function_name}.zip"
  function_timeout_in_seconds = 5
}


# API Gateway service root
resource "aws_api_gateway_rest_api" "api" {
  name = "api-gateway"
  description = "handles requests to our API"
  endpoint_configuration {
    types = ["REGIONAL"] 
  }
  
}

# API Gateway URL path that will be used to call our service
resource "aws_api_gateway_resource" "my_ip" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  parent_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
  path_part   = "ip"
}

# API Gateway method of execution
resource aws_api_gateway_method my_ip {
  rest_api_id = aws_api_gateway_resource.my_ip.rest_api_id
  resource_id = aws_api_gateway_resource.my_ip.id
  authorization = "NONE"
  http_method = "GET"
}

# API Gateway integration request
resource aws_api_gateway_integration my_ip {
  rest_api_id = aws_api_gateway_method.my_ip.rest_api_id
  resource_id = aws_api_gateway_method.my_ip.resource_id
  http_method = aws_api_gateway_method.my_ip.http_method
  type = "MOCK"
  request_templates = {
    "application/json" = <<TEMPLATE
{
  "statusCode": 200
}
TEMPLATE
  }
}

# API Gateway method response
resource aws_api_gateway_method_response my_ip {
  rest_api_id = aws_api_gateway_method.my_ip.rest_api_id
  resource_id = aws_api_gateway_method.my_ip.resource_id
  http_method = aws_api_gateway_method.my_ip.http_method
  status_code = 200
}

resource aws_api_gateway_integration_response my_ip {
  rest_api_id = aws_api_gateway_integration.my_ip.rest_api_id
  resource_id = aws_api_gateway_integration.my_ip.resource_id
  http_method = aws_api_gateway_integration.my_ip.http_method
  status_code = 200
  response_templates = {
    "application/json" = <<TEMPLATE
{
    "ip" : "$context.identity.sourceIp",
    "userAgent" : "$context.identity.userAgent",
    "time" : "$context.requestTime",
    "epochTime" : "$context.requestTimeEpoch"
}
TEMPLATE
  }
}

resource aws_api_gateway_deployment my_ip {
  depends_on = [aws_api_gateway_integration.my_ip]
  rest_api_id = aws_api_gateway_rest_api.api.id
  description = "Deployed ${timestamp()}"

  stage_name = "demo"
}



output my_ip_url {
  value = "${aws_api_gateway_deployment.my_ip.invoke_url}/${aws_api_gateway_resource.my_ip.path_part}"
}















resource "aws_lambda_function" "function" {
  function_name = local.function_name
  handler       = "index.lambda_handler"
  runtime       = "python3.9"
  timeout       = 5

  filename         = local.function_zip_file
  source_code_hash = data.archive_file.function_zip.output_base64sha256

  role = aws_iam_role.function_role.arn

  # environment {
  #   variables = {
  #     ENVIRONMENT = local.env_name
  #   }
  # }
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