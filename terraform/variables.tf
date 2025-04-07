### PROVIDER VARS ###
variable "aws_account_number" {
  type        = string
  description = "Account number"
}
variable "aws_region" {
  type        = string
  description = "AWS region where resources will be created"
}
variable "aws_profile" {
  type        = string
  description = "AWS region where resources will be created"
}
### APP VARS ###
variable "secrets_manager_arn" {
  type        = string
  description = "ARN of the secret this Lambda will access"
}
variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, sandbox, prod)"
}
variable "product_key" {
  type        = string
  description = "ASU product key."
}
variable "lambda_bucket" {
  type        = string
  description = "S3 bucket for uploading Lambda zip artifacts"
}
variable "log_retention_in_days" {
  type        = number
  description = "Number of days to retain Lambda logs in CloudWatch"
}
