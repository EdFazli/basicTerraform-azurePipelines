###################
# Calling Modules #
###################

#-------------------VPC-------------------#

module "base_vpc_setup" {
    source = "./modules/vpc"

}