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
  source = "../../../modules/services/webserver-cluster"

  cluster_name = "webserver-prod"
  db_remote_state_bucket = "terraform-up-and-running-state444a4"
  db_remote_state_key = "prod/data-stores/mysql/terraform.tfstate"

  instance_type = "t2.micro"
  min_size = 1
  max_size = 2
}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  scheduled_action_name = "scale-out-during-business-hounrs"
  min_size = 2
  max_size = 2
  desired_capacity = 2
  recurrence = "0 9 * * *"
  autoscaling_group_name = "${module.webserver-cluster.asg_name}"
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  scheduled_action_name = "scale-in-at-night"
  min_size = 2
  max_size = 2
  desired_capacity = 2
  recurrence = "0 17 * * *"
  autoscaling_group_name = "${module.webserver-cluster.asg_name}"
}