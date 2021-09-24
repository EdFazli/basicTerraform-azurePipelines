#########################
# variables declaration #
#########################
#Define VPC Address Space
variable "vpc_address_space" {
  type = map(any)
  default = {
    SIT  = "10.8.0.0/23"
    UAT = "10.9.0.0/22"
    PROD = "10.10.0.0/20"
  }
}

#Define Subnet Address Space
variable "subnet_address_space" {
  type = map(any)
  default = {
    SIT  = ["10.8.0.0/24"]
    UAT = ["10.9.0.0/24", "10.9.1.0/24"]
    PROD = ["10.10.0.0/24", "10.10.1.0/24", "10.10.2.0/24"]
  }
}