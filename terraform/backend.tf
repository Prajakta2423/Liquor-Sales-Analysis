terraform {
  backend "s3" {
    bucket = "terraform-state-liquor-sales"
    key    = "data-pipeline/terraform.tfstate"
    region = "us-east-1"
  }
}
