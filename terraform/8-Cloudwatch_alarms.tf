# Resource: aws_autoscaling_policy
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy
resource "aws_autoscaling_policy" "upCPU95" {
  name                   = "UpscaleCPU95"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 240
  autoscaling_group_name = aws_eks_node_group.noderunners.resources[0].autoscaling_groups[0].name
}

resource "aws_autoscaling_policy" "downCPU15" {
  name                   = "DownscaleCPU15"
  scaling_adjustment     = -2
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 3000
  autoscaling_group_name = aws_eks_node_group.noderunners.resources[0].autoscaling_groups[0].name
}

# Resource: aws_cloudwatch_metric_alarm
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm
resource "aws_cloudwatch_metric_alarm" "CPUauto95" {
  alarm_name          = "CPUautoscale95"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "240"
  statistic           = "Average"
  threshold           = "95"

  dimensions = {
    AutoScalingGroupName = aws_eks_node_group.noderunners.resources[0].autoscaling_groups[0].name
  }

  alarm_description = "Autoscale when more than 95% CPU"
  alarm_actions     = [aws_autoscaling_policy.upCPU95.arn]
}

resource "aws_cloudwatch_metric_alarm" "CPUauto15" {
  alarm_name          = "CPUautoscale15"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "1800"
  statistic           = "Average"
  threshold           = "15"

  dimensions = {
    AutoScalingGroupName = aws_eks_node_group.noderunners.resources[0].autoscaling_groups[0].name
  }

  alarm_description = "Autoscale when more than 95% CPU"
  alarm_actions     = [aws_autoscaling_policy.downCPU15.arn]
}
