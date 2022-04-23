# Resource: aws_autoscaling_policy
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy

resource "aws_autoscaling_policy" "downCPU15" {
  name                   = "DownscaleCPU15"
  scaling_adjustment     = -3
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 3600
  autoscaling_group_name = aws_eks_node_group.noderunners.resources[0].autoscaling_groups[0].name
}

resource "aws_cloudwatch_metric_alarm" "CPUauto15" {
  alarm_name          = "CPUautoscale15"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "8"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "15"

  dimensions = {
    AutoScalingGroupName = aws_eks_node_group.noderunners.resources[0].autoscaling_groups[0].name
  }

  alarm_description = "Downscale when less than 15% CPU"
  alarm_actions     = [aws_autoscaling_policy.downCPU15.arn]
}
