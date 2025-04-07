output "sf_query_lambda_name" {
  description = "Query Lambda function name"
  value       = aws_lambda_function.sf_query.function_name
}

output "sf_write_lambda_name" {
  description = "Write Lambda function name"
  value       = aws_lambda_function.sf_write.function_name
}

output "salesforce_layer_arn" {
  description = "ARN of the deployed Salesforce shared layer"
  value       = aws_lambda_layer_version.salesforce_layer.arn
}

output "query_log_group" {
  description = "CloudWatch log group for sf-query"
  value       = aws_cloudwatch_log_group.sf_query_logs.name
}

output "write_log_group" {
  description = "CloudWatch log group for sf-write"
  value       = aws_cloudwatch_log_group.sf_write_logs.name
}
