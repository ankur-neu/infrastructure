

// ******************** auto scaling group *************


resource "aws_launch_configuration" "alc" {
  depends_on    = [aws_db_instance.rds]
  name_prefix   = "asg_launch_config"
  image_id      = data.aws_ami.ami.id
  instance_type = "t2.micro"
  user_data     = <<-EOF
    #!/bin/bash
    sudo apt-get update
    curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
    sudo apt-get install -y nodejs
    sudo apt install npm

    echo export DB_HOST=${aws_db_instance.rds.address} >> /etc/profile
    echo export PORT=${var.app_port} >> /etc/profile
    echo export DB_NAME=${var.db_name} >> /etc/profile
    echo export DB_HOST=${aws_db_instance.rds.address} >> /etc/profile
    echo export DB_USER=${var.db_user} >> /etc/profile
    echo export DB_PASS=${var.db_pass} >> /etc/profile
    echo export DB_PORT=${var.sg_db_ingress_p1} >> /etc/profile
    echo export BUCKET_NAME=${aws_s3_bucket.bucket.id} >> /etc/profile
  EOF

  key_name                    = aws_key_pair.ubuntu.key_name
  iam_instance_profile        = aws_iam_instance_profile.iam_profile.name
  security_groups             = ["${aws_security_group.application.id}"]
  associate_public_ip_address = true
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  depends_on = [aws_launch_configuration.alc, aws_subnet.subnet_infra]
  name       = "autoScalingGroup"
  max_size   = 1
  min_size   = 1
  // health_check_grace_period = 60
  desired_capacity     = 1
  launch_configuration = aws_launch_configuration.alc.name
  vpc_zone_identifier  = values(aws_subnet.subnet_infra)[*].id
  target_group_arns    = ["${aws_lb_target_group.lb_targetgroup.arn}"]
  default_cooldown     = "60"
  tag {
    key                 = "Name"
    value               = "csye6225_ec2"
    propagate_at_launch = true
  }
}



resource "aws_lb" "aws_lb_app" {
  depends_on                 = [aws_db_instance.rds, aws_security_group.lb_sg]
  name                       = "webapp-lb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.lb_sg.id]
  subnets                    = values(aws_subnet.subnet_infra)[*].id
  ip_address_type            = "ipv4"
  enable_deletion_protection = false

  tags = {
    Environment = var.environment
  }
}

# Security Group for Loadbalancer
resource "aws_security_group" "lb_sg" {
  depends_on  = [aws_vpc.vpc_infra]
  name        = "aws_lb_sg"
  vpc_id      = aws_vpc.vpc_infra.id
  description = "Allow ALB inbound traffic"

  ingress {
    description      = var.sg_lb_ingress_desc
    from_port        = var.sg_app_ingress_p2
    to_port          = var.sg_app_ingress_p2
    protocol         = var.protocol
    cidr_blocks      = [var.sg_app_cidr]
    ipv6_cidr_blocks = [var.sg_app_cidr_ip6]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.sg_app_cidr]
    ipv6_cidr_blocks = [var.sg_app_cidr_ip6]
  }

}

# load balancer target group
resource "aws_lb_target_group" "lb_targetgroup" {
  depends_on = [aws_vpc.vpc_infra]
  name       = "LoadBalancerTargetGroup"
  port       = "3000"
  protocol   = "HTTP"
  vpc_id     = aws_vpc.vpc_infra.id
  stickiness {
    type            = "lb_cookie"
    cookie_duration = 1800
    enabled         = true
  }
  health_check {
    interval            = 55
    timeout             = 45
    healthy_threshold   = 3
    unhealthy_threshold = 10
    path                = "/health"
  }
}


# Listener for LoadBalancer
resource "aws_lb_listener" "a_lb_listener" {
  depends_on        = [aws_lb.aws_lb_app]
  load_balancer_arn = aws_lb.aws_lb_app.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_targetgroup.arn
  }
}

#Autoscaling Attachment
resource "aws_autoscaling_attachment" "alb_asg" {
  depends_on             = [aws_lb_target_group.lb_targetgroup, aws_autoscaling_group.asg]
  alb_target_group_arn   = aws_lb_target_group.lb_targetgroup.arn
  autoscaling_group_name = aws_autoscaling_group.asg.id
}

# scale-up alarm metrics
resource "aws_autoscaling_policy" "cpu_policy_scaleup" {
  depends_on             = [aws_autoscaling_group.asg]
  name                   = "cpu-policy-scaleup"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1"
  cooldown               = "60"
  policy_type            = "SimpleScaling"
}

# scale-down alarm metrics
resource "aws_autoscaling_policy" "cpu_policy_scaledown" {
  name                   = "cpu-policy-scaledown"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1"
  cooldown               = "60"
  policy_type            = "SimpleScaling"
}