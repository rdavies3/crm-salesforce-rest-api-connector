resource "aws_iam_role" "lambda_exec_role" {
  name = "sf-query-${var.environment}-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "lambda_secrets_policy" {
  name = "sf-query-${var.environment}-secrets-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["secretsmanager:GetSecretValue"],
      Resource = var.secrets_manager_arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "secrets_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_secrets_policy.arn
}

locals {
  lambda_name = "sf-query-${var.environment}"
  zip_file    = "${path.module}/${local.lambda_name}.zip"
}

resource "null_resource" "build_lambda_zip" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command     = "./build-lambda-zip.sh ${var.environment}"
    working_dir = path.module
  }
}

resource "aws_lambda_function" "sf_query_lambda_function" {
  function_name = "sf-query-${var.environment}"
  runtime       = "nodejs18.x"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "app.handler"
  timeout       = 30

  filename         = local.zip_file
  source_code_hash = filebase64sha256(local.zip_file)

  depends_on = [
    aws_iam_role_policy_attachment.secrets_attach
  ]
}
