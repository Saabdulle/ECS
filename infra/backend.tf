terraform {
  backend "s3" {
    bucket       = "saeed-plane-terraform-state-lock-1"
    key          = "plane/prod/terraform.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true
  }
}
