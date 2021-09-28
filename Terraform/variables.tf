#########################
# variables declaration #
#########################
locals {
  env = terraform.workspace
}
variable "region" {
  description = "Which region you want to provision your resources?"
  type        = map(any)
  default     = {
    SIT         = "ap-southeast-1"
    UAT         = "ap-southeast-1"
    PROD        = "ap-southeast-1"
    PROD-SYDNEY = "ap-southeast-2"
  }
}

variable "provider_env_roles" {
  type        = map(any)
  default     = {
    SIT         = "arn:aws:iam::452342606332:role/OrganizationAccountAccessRole"
    UAT         = "arn:aws:iam::699388596268:role/OrganizationAccountAccessRole"
    PROD        = "arn:aws:iam::649377927085:role/OrganizationAccountAccessRole"
    PROD-SYDNEY = "arn:aws:iam::649377927085:role/OrganizationAccountAccessRole"
  }
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

