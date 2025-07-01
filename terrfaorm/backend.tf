terraform {
  backend "s3" {
    bucket = "sanju-sanju-bucket3"
    key = "eks-rds-fullstack/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "sanju-sanju-table"
    encrypt = true
  }
}
