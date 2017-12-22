provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "terraform-up-and-running-state444a4"
    region = "us-east-1"
    key = "prod/services/webserver-cluster/terraform.tfstate"
    encrypt = true
  }
}
module "webserver-cluster" {
  source = "git::git@github.com:markesha/tf-modules.git//services/webserver-cluster?ref=v0.0.1"

  cluster_name = "webserver-prod"
  db_remote_state_bucket = "terraform-up-and-running-state444a4"
  db_remote_state_key = "prod/data-stores/mysql/terraform.tfstate"

  instance_type = "t2.micro"
  min_size = 1
  max_size = 2
  
  enable_autoscaling = false
}