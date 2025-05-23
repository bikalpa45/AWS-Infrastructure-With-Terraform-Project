
module "bikalpa-rds" {
    source      = "../module/rds"

    ENVIRONMENT = var.ENVIRONMENT
    AWS_REGION  = var.AWS_REGION
    vpc_private_subnet1 = var.vpc_private_subnet1
    vpc_private_subnet2 = var.vpc_private_subnet2
    vpc_id = var.vpc_id
}

resource "aws_security_group" "bikalpa_webservers"{
  tags = {
    Name = "${var.ENVIRONMENT}-bikalpa-webservers"
  }
  
  name          = "${var.ENVIRONMENT}-bikalpa-webservers"
  description   = "Created by Levelup"
  vpc_id        = var.vpc_id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.SSH_CIDR_WEB_SERVER}"]

  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Resource key pair
resource "aws_key_pair" "bikalpa_key" {
  key_name      = "bikalpa_key"
  public_key    = file(var.public_key_path)
}

resource "aws_launch_template" "launch_template_webserver" {
  name_prefix   = "launch-template-webserver"
  image_id      = lookup(var.AMIS, var.AWS_REGION)
  instance_type = var.INSTANCE_TYPE
  key_name      = aws_key_pair.bikalpa_key.key_name

  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt-get update
              apt-get -y install net-tools nginx
              MYIP=`ifconfig | grep -E '(inet 10)|(addr:10)' | awk '{ print $2 }' | cut -d ':' -f2`
              echo 'Welcome!!, This is the instance IP: '$MYIP > /var/www/html/index.html
            EOF
  )

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.bikalpa_webservers.id]
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 20
      volume_type = "gp2"
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "webserver"
    }
  }
}

resource "aws_autoscaling_group" "bikalpa_webserver" {
  name                      = "bikalpa_WebServers"
  max_size                  = 2
  min_size                  = 1
  desired_capacity          = 1
  health_check_grace_period = 30
  health_check_type         = "EC2"
  vpc_zone_identifier       = [var.vpc_public_subnet1, var.vpc_public_subnet2]
  target_group_arns         = [aws_lb_target_group.load-balancer-target-group.arn]
  force_delete              = true

  launch_template {
    id      = aws_launch_template.launch_template_webserver.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "bikalpa_webserver"
    propagate_at_launch = true
  }
}

# Application load balancer for app server
resource "aws_lb" "bikalpa-load-balancer" {
  name               = "${var.ENVIRONMENT}-bikalpa-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.bikalpa_webservers_alb.id]
  subnets            = ["${var.vpc_public_subnet1}", "${var.vpc_public_subnet2}"]

}

# Add Target Group
resource "aws_lb_target_group" "load-balancer-target-group" {
  name     = "load-balancer-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

# Adding HTTP listener
resource "aws_lb_listener" "webserver_listner" {
  load_balancer_arn = aws_lb.bikalpa-load-balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.load-balancer-target-group.arn
    type             = "forward"
  }
}

output "load_balancer_output" {
  value = aws_lb.bikalpa-load-balancer.dns_name
}
