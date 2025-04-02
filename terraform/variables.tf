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
variable "environment" {
  type        = string
  description = "Where we are in the life of the app."
}
variable "product_key" {
  type        = string
  description = "ASU product key."
}
