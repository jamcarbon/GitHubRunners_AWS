# Resource: aws_autoscaling_policy
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy

resource "aws_autoscaling_policy" "downCPU5" {
  name                   = "DownscaleCPU5"
  scaling_adjustment     = -3     # reduce the capacity by 3 after the CPU usage is less than 5% for more than 10 minutes
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 900   # use this policy again after 15 minutes
  autoscaling_group_name = aws_eks_node_group.noderunners.resources[0].autoscaling_groups[0].name
}

resource "aws_cloudwatch_metric_alarm" "CPUauto5" {
  alarm_name          = "CPUautoscale5"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "10"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "5"

  dimensions = {
    AutoScalingGroupName = aws_eks_node_group.noderunners.resources[0].autoscaling_groups[0].name
  }

  alarm_description = "Downscale when less than 5% CPU"
  alarm_actions     = [aws_autoscaling_policy.downCPU5.arn]
}

resource "aws_autoscaling_policy" "downCPU60" {
  name                   = "DownscaleCPU5"
  scaling_adjustment     = -3       # reduce the capacity by 3 after the CPU usage is less than 60% for more than 15 minutes
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 1800     # use this policy again after 30 minutes
  autoscaling_group_name = aws_eks_node_group.noderunners.resources[0].autoscaling_groups[0].name
}

resource "aws_cloudwatch_metric_alarm" "CPUauto60" {
  alarm_name          = "CPUautoscale60"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "15"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "60"

  dimensions = {
    AutoScalingGroupName = aws_eks_node_group.noderunners.resources[0].autoscaling_groups[0].name
  }

  alarm_description = "Downscale when less than 60% CPU"
  alarm_actions     = [aws_autoscaling_policy.downCPU60.arn]
}
