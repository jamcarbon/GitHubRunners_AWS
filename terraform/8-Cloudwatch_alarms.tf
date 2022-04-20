resource "aws_autoscaling_group" "autoscalegroup" {
  name                 = "autoscalegroup"
  min_size             = 1
  max_size             = 4
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity     = 1
  default_cooldown     = 120
  vpc_zone_identifier  = [aws_subnet.private-us-east-1a.id, aws_subnet.private-us-east-1b.id]

  role_arn                = aws_iam_role.nodes.arn

  tag {
    key                 = "Name"
    value               = "AutoscaleGroup"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "asp" {
  name                   = "autoscalepolicy"
  scaling_adjustment     = 2
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.autoscalegroup
}

resource "aws_cloudwatch_metric_alarm" "95" {
  alarm_name          = "CPUautoscale95"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "95"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.autoscalegroup
  }

  alarm_description = "Autoscale when more than 95% CPU"
  alarm_actions     = [aws_autoscaling_policy.95.autoscalepolicy]
}
