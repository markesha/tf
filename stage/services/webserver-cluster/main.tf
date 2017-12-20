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
resource "aws_launch_configuration" "example" {

  instance_type = "t2.micro"
  user_data = "${data.template_file.user_data.rendered}"

  security_groups = ["${aws_security_group.instance.id}"]
  image_id = "ami-40d28157"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elb" "example" {
  name = "terraform-asg-example"
  availability_zones = ["${data.aws_availability_zones.all.names}"]
  security_groups = ["${aws_security_group.elb.id}"]

  "listener" {
    instance_port = "${var.server_port}"
    instance_protocol = "http"
    lb_port = "${var.elb_port}"
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    interval = 30
    target = "HTTP:${var.server_port}/"
    timeout = 3
    unhealthy_threshold = 2
  }
}
resource "aws_autoscaling_group" "example" {
  availability_zones = ["${data.aws_availability_zones.all.names}"]
  launch_configuration = "${aws_launch_configuration.example.id}"

  load_balancers = ["${aws_elb.example.name}"]
  health_check_type = "ELB"

  max_size = 2
  min_size = 1
  desired_capacity = 2
  
  tag {
    key = "Name"
    value = "terraform-asg-example"
    propagate_at_launch = true
  }
}
resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port = "${var.server_port}"
    protocol = "tcp"
    to_port = "${var.server_port}"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "elb" {
  name = "terraform-example-elb"

  ingress {
    from_port = "${var.elb_port}"
    protocol = "tcp"
    to_port = "${var.elb_port}"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_availability_zones" "all" {}

data "terraform_remote_state" "db" {
  backend = "s3"

  config {
    bucket = "terraform-up-and-running-state444a4"
    region = "us-east-1"
    key = "stage/data-stores/mysql/terraform.tfstate"
  }
}

data "template_file" "user_data" {
  template = "${file("user-data.sh")}"

  vars {
    server_port = "${var.server_port}"
    db_address = "${data.terraform_remote_state.db.address}"
    db_port = "${data.terraform_remote_state.db.port}"
  }
}