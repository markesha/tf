provider "aws" {
  region = "us-east-1"
}
module "mysql" {
  source = "../../../modules/data-stores/mysql/"

  instance_class = "db.t2.micro"
  db_name = "stage"
  db_password = "stagedbpass"
}
terraform {
  backend "s3" {
    bucket = "terraform-up-and-running-state444a4"
    region = "us-east-1"
    key = "stage/data-stores/mysql/terraform.tfstate"
    encrypt = true
  }
}