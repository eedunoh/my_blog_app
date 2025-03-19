# CloudWatch Alarm: CPU >= 5%
resource "aws_cloudwatch_metric_alarm" "cpu_gte_5" {
  alarm_name          = "cpu_gte_5"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 5.0
  alarm_actions       = [aws_autoscaling_policy.scale_up_cpu_step.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.blog_app_asg.name
  }
}




# CloudWatch Alarm: CPU < 5% - Remove all On-Demand, return to 1 Spot
resource "aws_cloudwatch_metric_alarm" "cpu_below_5" {
  alarm_name          = "cpu_below_5"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 5.0
  alarm_actions       = [aws_autoscaling_policy.scale_down_to_1_spot.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.blog_app_asg.name
  }
}