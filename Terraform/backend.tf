####################
# define terraform #
####################
terraform {
    required_version = ">=1.0"
    backend "s3" {
        bucket = "edfazli92-terraform-statefile"
        key    = "tf/"
        region = "ap-southeast-1"
        encrypt = true
        dynamodb_table = "tfstatelocking"
  }
}