resource "aws_cloudwatch_log_group" "sf_query_logs" {
  name              = "/aws/lambda/${aws_lambda_function.sf_query.function_name}"
  retention_in_days = var.log_retention_in_days
}

resource "aws_cloudwatch_log_group" "sf_write_logs" {
  name              = "/aws/lambda/${aws_lambda_function.sf_write.function_name}"
  retention_in_days = var.log_retention_in_days
}
