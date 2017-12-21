provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "terraform-up-and-running-state444a4"
    region = "us-east-1"
    key = "stage/services/webserver-cluster/terraform.tfstate"
    encrypt = true
  }
}
module "webserver-cluster" {
  source = "../../../../modules/services/webserver-cluster"

  cluster_name = "webserver-stage"
  db_remote_state_bucket = "terraform-up-and-running-state444a4"
  db_remote_state_key = "stage/data-stores/mysql/terraform.tfstate"
  
  instance_type = "t2.micro"
  min_size = 1
  max_size = 2
}

resource "aws_security_group_rule" "allow_testing_inbound" {
  from_port = 12345
  protocol = "tcp"
  security_group_id = "${module.webserver-cluster.elb_security_group_id}"
  to_port = 12345
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}