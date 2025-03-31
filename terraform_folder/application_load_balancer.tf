resource "aws_lb" "app_alb" {
  name               = "blog-app-alb"
  internal           = false                          # internal = false → The ALB is public-facing (accessible via the internet).
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = slice(data.aws_subnets.public_subnets.ids, 0, 2)     # using subnet_ids of the default (existing) vpc as defined in the main.tf file. Alb will use the two (2) public subnets 

  # You can type this in terminal (bash) to get a list of your subnet:
  # aws ec2 describe-subnets --query "Subnets[*].{ID:SubnetId, Public:MapPublicIpOnLaunch, AZ:AvailabilityZone}"


  enable_deletion_protection = false
}


resource "aws_lb_target_group" "alb_tg" {
  name     = "AlbTargetGroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.existing_vpc.id   # using the default (existing) vpc_id as defined in the main.tf file


    # Without this, the ALB won’t know if the instances are healthy!
    # The ALB does NOT replace unhealthy instances—it just stops sending traffic to them.

   health_check {
    path                = "/health"
    interval            = 30    # The ALB performs a health check every 30 seconds.
    timeout             = 15    # The ALB waits 5 seconds for a response before marking the check as failed.
    healthy_threshold   = 2      # The target (EC2 instance) must pass the health check 2 times in a row to be marked as healthy.
    unhealthy_threshold = 4      # The target must fail the health check 2 times in a row to be marked as unhealthy.
    }

}


# Without this listener, the ALB won’t know how to handle incoming requests.
# The ALB itself doesn’t forward traffic unless you explicitly tell it to forward requests to a Target Group.
# The listener defines which port (e.g., 80 for HTTP) and which Target Group the ALB should send traffic to

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}



output "alb_target_group_id" {
  value = aws_lb_target_group.alb_tg.arn
}

output "app_alb_id" {
  value = aws_lb.app_alb.arn
}