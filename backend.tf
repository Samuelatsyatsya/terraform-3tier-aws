terraform {
  backend "s3" {
    bucket         = "3tier-state-bucket"
    key            = "dev/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}
