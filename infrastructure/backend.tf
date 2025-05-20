terraform {
  backend "s3" {
    bucket = "learner-terraform-state"
    key    = "dev/terraform.tfstate"
    region = "ap-southeast-1"
  }
}
