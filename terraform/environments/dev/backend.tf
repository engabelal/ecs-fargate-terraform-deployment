terraform {
  backend "s3" {
    bucket         = "terraform-state-url-shortener-501235162976"
    key            = "dev/terraform.tfstate"
    region         = "eu-north-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
