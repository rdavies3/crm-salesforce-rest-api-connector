variable "aws_region" {
  type        = string
  description = "AWS region where resources will be created"
}

variable "lambda_name" {
  type        = string
  description = "Name of the Lambda function"
}

variable "lambda_handler" {
  type        = string
  description = "Handler method (e.g., app.handler)"
}

variable "lambda_runtime" {
  type        = string
  description = "Lambda runtime (e.g., nodejs18.x)"
}

variable "lambda_memory_size" {
  type        = number
  description = "Memory allocated to Lambda in MB"
  default     = 128
}

variable "lambda_timeout" {
  type        = number
  description = "Timeout in seconds for the Lambda function"
  default     = 30
}

variable "lambda_source_path" {
  type        = string
  description = "Path to directory with Lambda source code"
}

variable "secrets_manager_arn" {
  type        = string
  description = "ARN of the secret this Lambda will access"
}
