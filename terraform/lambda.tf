resource "aws_iam_role" "lambda_exec_role" {
  name = "sf-query-${var.app_lifecycle}-exec-role"

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
  name = "sf-query-${var.app_lifecycle}-secrets-policy"

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

data "archive_file" "sf_query_lambda_zip" {
  type        = "zip"
  source_dir  = "../lambdas/sf-query"
  output_path = "${path.module}/sf-query-${var.app_lifecycle}.zip"
}

resource "aws_lambda_function" "sf_query_lambda_function" {
  function_name = "sf-query-${var.app_lifecycle}"
  runtime       = "nodejs18.x"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = app.handler
  timeout       = 30

  filename         = data.archive_file.sf_query_lambda_zip.output_path
  source_code_hash = filebase64sha256(data.archive_file.sf_query_lambda_zip.output_path)

  depends_on = [
    aws_iam_role_policy_attachment.secrets_attach
  ]
}
