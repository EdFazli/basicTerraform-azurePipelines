#########################
# variables declaration #
#########################
#Define vpc
variable "vpc" {
  type = map(any)
  default = {
    SIT  = "10.210.0.0/16"
    UAT = "10.220.0.0/16"
    PROD = "10.101.0.0/16"
    PROD-SYDNEY = "10.110.0.0/16"
  }
}

#Define private_subnets
variable "private_subnets" {
  type = map(any)
  default = {
    SIT  = ["10.8.0.0/24"]
    UAT = ["10.9.0.0/24", "10.9.1.0/24"]
    PROD = ["10.10.0.0/24", "10.10.1.0/24", "10.10.2.0/24"]
    PROD-SYDNEY = []
  }
}