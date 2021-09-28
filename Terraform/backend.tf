####################
# define terraform #
####################
terraform {
    required_version = ">=1.0"
    backend "s3" {
        bucket = "edfazli92-terraform-statefile"
        key    = "tf/terraform.tfstate"
        region = "ap-southeast-1"
        encrypt = true
  }
}