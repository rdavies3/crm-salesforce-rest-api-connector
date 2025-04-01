# application
app_lifecycle = "dev"

# providers
aws_account_number  = "982081057374"
aws_region          = "us-west-2"
secrets_manager_arn = "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_id}:secret:dev/sandbox-imrQ1R"
