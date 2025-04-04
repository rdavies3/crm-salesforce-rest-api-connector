locals {
  query_zip        = "${path.module}/lambda/sf-query-${var.environment}.zip"
  write_zip        = "${path.module}/lambda/sf-write-${var.environment}.zip"
  layer_zip        = "${path.module}/lambda/salesforce-lib-layer-${var.environment}.zip"
  layer_name       = "salesforce-lib-${var.environment}"
  lambda_role_name = "lambda-exec-${var.environment}"
}

resource "aws_iam_role" "lambda_exec" {
  name = local.lambda_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_exec" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "secrets_manager_access" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_lambda_layer_version" "salesforce_layer" {
  layer_name          = local.layer_name
  filename            = local.layer_zip
  compatible_runtimes = ["nodejs18.x"]
  source_code_hash    = filebase64sha256(local.layer_zip)
}

resource "aws_lambda_function" "sf_query" {
  function_name    = "sf-query-${var.environment}"
  handler          = "app.handler"
  runtime          = "nodejs18.x"
  timeout          = 10
  filename         = local.query_zip
  source_code_hash = filebase64sha256(local.query_zip)

  role   = aws_iam_role.lambda_exec.arn
  layers = [aws_lambda_layer_version.salesforce_layer.arn]
}

resource "aws_lambda_function" "sf_write" {
  function_name    = "sf-write-${var.environment}"
  handler          = "app.handler"
  runtime          = "nodejs18.x"
  timeout          = 10
  filename         = local.write_zip
  source_code_hash = filebase64sha256(local.write_zip)

  role   = aws_iam_role.lambda_exec.arn
  layers = [aws_lambda_layer_version.salesforce_layer.arn]
}
