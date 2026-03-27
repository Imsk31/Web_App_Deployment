terraform {
  backend "s3" {
    region = "us-east-1"
    bucket = "shubham-terraform-bucket-042831095536"
    key = "statefile/terraform.tfstate"
    use_lockfile = true
    encrypt = true
  }
}
