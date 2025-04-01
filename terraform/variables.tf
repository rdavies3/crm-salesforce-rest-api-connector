### PROVIDER VARS ###
variable "aws_account_number" {
  type        = string
  description = "Account number"
}
variable "aws_region" {
  type        = string
  description = "AWS region where resources will be created"
}

variable "secrets_manager_arn" {
  type        = string
  description = "ARN of the secret this Lambda will access"
}
