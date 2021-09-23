####################
# define terraform #
####################
terraform {
    required_version = ">=1.0"
    backend "s3" {
        bucket = "edfazli92-terraform-statefile"
        key    = "path/to/my/key"
        region = "ap-southeast-1"
  }
}