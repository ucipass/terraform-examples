
locals {
  function_name1               = "${lower(var.app_name)}-${lower(var.app_environment)}-function1"
  function_source_dir1 = "${path.module}/aws_lambda_functions/function1"
  function_zip_file1   = "${path.module}/aws_lambda_functions/${local.function_name1}.zip"
  function_name2               = "${lower(var.app_name)}-${lower(var.app_environment)}-function2"
  function_source_dir2 = "${path.module}/aws_lambda_functions/function2"
  function_zip_file2   = "${path.module}/aws_lambda_functions/${local.function_name2}.zip"
  function_handler            = "index.lambda_handler"
  function_runtime            = "python3.9"
  function_timeout_in_seconds = 30
}



resource "aws_lambda_function" "function1" {
  function_name = local.function_name1
  handler       = "index.lambda_handler"
  runtime       = "python3.9"
  timeout       = local.function_timeout_in_seconds

  filename         = local.function_zip_file1
  source_code_hash = data.archive_file.function_zip1.output_base64sha256

  role = aws_iam_role.function_role.arn

}

data "archive_file" "function_zip1" {
  type        = "zip"
  source_dir = local.function_source_dir1
  output_path = local.function_zip_file1
}

resource "aws_lambda_function" "function2" {
  function_name = local.function_name2
  handler       = "index.lambda_handler"
  runtime       = "python3.9"
  timeout       = local.function_timeout_in_seconds

  filename         = local.function_zip_file2
  source_code_hash = data.archive_file.function_zip2.output_base64sha256

  role = aws_iam_role.function_role.arn

}

data "archive_file" "function_zip2" {
  type        = "zip"
  source_dir = local.function_source_dir2
  output_path = local.function_zip_file2
}

resource "aws_iam_role" "function_role" {
  name = "${local.function_name1}-role"

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

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.function_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}