terraform {
  backend "s3" {
    bucket = "my_project-terraform-state"
    key    = "prod/terraform.tfstate"
    region = "eu-north-1"
  }
}
