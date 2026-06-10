provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 1.10"

  backend "s3" {
    bucket       = "terraform-daycarescout"
    key          = "us-east-1/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
