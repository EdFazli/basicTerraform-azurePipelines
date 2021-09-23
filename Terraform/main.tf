####################
# define terraform #
####################
terraform {
    required_version = ">=1.0"
    backend "s3" {
        bucket = "edfazli92-terraform-statefile"
        key    = "edfazli92-terraform-statefile/"
        region = "ap-southeast-1"
  }
}