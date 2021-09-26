###################
# Calling Modules #
###################

#-------------------VPC-------------------#

module "initial_vpc_setup" {
    source = "./modules/vpc"

}