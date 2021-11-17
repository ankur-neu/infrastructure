

resource "aws_cloudwatch_metric_alarm" "cpu-alarm-scaleup" {
  alarm_name          = "cpu-alarm-scaleup"
  alarm_description   = "cpu-alarm-scaleup"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "5"
  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.asg.name}"
  }
  actions_enabled = true
  alarm_actions   = ["${aws_autoscaling_policy.cpu_policy_scaleup.arn}"]
}


resource "aws_cloudwatch_metric_alarm" "cpu-alarm-scaledown" {
  alarm_name          = "cpu-alarm-scaledown"
  alarm_description   = "cpu-alarm-scaledown"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "3"
  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.asg.name}"
  }
  actions_enabled = true
  alarm_actions   = ["${aws_autoscaling_policy.cpu_policy_scaledown.arn}"]
}


resource "aws_cloudwatch_log_group" "csye6225" {
  name = "csye6225"
}


resource "aws_cloudwatch_log_stream" "stream" {
  name           = "webapp"
  log_group_name = aws_cloudwatch_log_group.csye6225.name

}

resource "aws_iam_policy_attachment" "ec2_attach3" {
  name       = "ec2attach3"
  users      = [var.app_user_name]
  roles      = ["${aws_iam_role.ec2_service_role.name}"]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}