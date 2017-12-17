provider "aws" {
  region = "us-east-1"
}

resource "aws_launch_configuration" "example" {

  instance_type = "t2.micro"
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, world" > index.html
              nohup busybox httpd -f -p "${var.server_port}" &
              EOF

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


variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default = "8080"
}

variable "elb_port" {
  description = "The elb port for HTTP"
  default = "80"
}

data "aws_availability_zones" "all" {}
output "elb_dns_name" {
  value = "${aws_elb.example.dns_name}"
}