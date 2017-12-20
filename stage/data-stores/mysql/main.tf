provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "terraform-up-and-running-state444a4"
    region = "us-east-1"
    key = "stage/data-stores/mysql/terraform.tfstate"
    encrypt = true
  }
}
resource "aws_db_instance" "example" {
  engine = "mysql"
  allocated_storage = 10
  instance_class = "db.t2.micro"
  name = "example_database"
  username = "admin"
  password = "${var.db_password}"
}