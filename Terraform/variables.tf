#########################
# variables declaration #
#########################
locals {
  env = terraform.workspace
}
variable "region" {
    type = string
    description = "Which region you want to provision your resources?"
}

#Define IAM User Access Key
variable "access_key" {
  description = "The access_key that belongs to the IAM user"
  type        = string
  sensitive   = true
}

#Define IAM User Secret Key
variable "secret_key" {
  description = "The secret_key that belongs to the IAM user"
  type        = string
  sensitive   = true
}