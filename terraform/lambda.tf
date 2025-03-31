resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.lambda_name}-exec-role"

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
  name = "${var.lambda_name}-secrets-policy"

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

resource "null_resource" "build_lambda" {
  provisioner "local-exec" {
    command = <<EOT
      cd ${var.lambda_source_path}
      npm ci
      zip -r ../../lambda.zip . -x "events/*" -x "tests/*" -x "*.md" -x "samconfig.toml"
    EOT
  }

  triggers = {
    always_run = timestamp()
  }
}

resource "aws_lambda_function" "lambda_function" {
  function_name = var.lambda_name
  runtime       = var.lambda_runtime
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = var.lambda_handler
  timeout       = var.lambda_timeout
  memory_size   = var.lambda_memory_size

  filename         = "${path.module}/../lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/../lambda.zip")

  depends_on = [
    aws_iam_role_policy_attachment.secrets_attach,
    null_resource.build_lambda
  ]
}
