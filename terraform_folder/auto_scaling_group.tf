resource "aws_autoscaling_group" "blog_app_asg" {
  name = "blog_app_auto_scaling"
  availability_zones = ["eu-north-1a"]
  desired_capacity   = 1
  max_size           = 4
  min_size           = 1

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.blog_app_lt.id   # We attach our launch template here using the launch template id
        version = "$Latest"
      }
    }


  instances_distribution {
      on_demand_base_capacity                  = 0          # Start with Spot
      on_demand_percentage_above_base_capacity = 50         # 50% of instances are on-demand instances when new instances are added
      spot_allocation_strategy                 = "lowest-price"
    }
  }


  # Attach to Load Balancer (ALB) and turn on health checks
  target_group_arns     = [aws_lb_target_group.alb_tg.arn]    # Use "target_group_arns" if using ALB
  health_check_type      = "ELB"             # Ensures ELB performs health checks
  health_check_grace_period = 300            # Wait 5 mins before marking unhealthy. The reason for this is that the image may be large in size and would need more time to initialize. we dont want the ALB marking it unhealthy while its initializing.
}


# In AWS Step Scaling policies:

# Lower bound is inclusive: This means that the policy will trigger if the metric is equal to or greater than the lower bound value.

# Upper bound is exclusive: This means that the policy will trigger if the metric is strictly less than the upper bound value.



# Auto scaling policy: CPU >= 5% - Scale up based on step scaling
resource "aws_autoscaling_policy" "scale_up_cpu_step" {
  name                    = "scale_up_cpu_step"
  adjustment_type         = "ChangeInCapacity"                                # Incremental scaling
  autoscaling_group_name  = aws_autoscaling_group.blog_app_asg.name
  policy_type             =  "StepScaling"                                    # Explicitly define Step Scaling

  # Step Scaling Policy for CPU Utilization
  step_adjustment {
    metric_interval_lower_bound = 5     # If CPU is 5%-15%
    metric_interval_upper_bound = 16
    scaling_adjustment = 1              # Scale up by 1 instance
  }

  step_adjustment {
    metric_interval_lower_bound = 16    # If CPU is 16% and above
    scaling_adjustment = 2              # Scale up by 2 instances
  }
}



# Auto scaling policy: CPU < 5% - Scale down by 1 instance, but ensure not less than 1 instance
resource "aws_autoscaling_policy" "scale_down_to_1_spot" {
  name                    = "scale_down_to_1_spot"
  adjustment_type         = "ChangeInCapacity"                              # Use ChangeInCapacity for incremental scaling
  autoscaling_group_name  = aws_autoscaling_group.blog_app_asg.name
  policy_type             = "StepScaling"                                   # Explicitly define Step Scaling

  # Step Scaling Policy for CPU < 5%
  step_adjustment {
    metric_interval_upper_bound = 5       # If CPU usage < 5%
    scaling_adjustment = -1               # Scale down by 1 instance if CPU usage < 5%
  }

  # Add a step adjustment with no upper bound to allow step scaling to work properly
  step_adjustment {
    metric_interval_lower_bound = 5     # If CPU usage is 5% or more (no upper bound specified)
    scaling_adjustment = 0              # No scaling action but allows step scaling to proceed
  }
}


output "asg_group_arn" {
    value = aws_autoscaling_group.blog_app_asg.arn
}