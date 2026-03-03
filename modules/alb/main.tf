resource "aws_alb" "alb" {
  name= "ha-webapp-alb"
  load_balancer_type = "application"
  subnets = var.public_subnets

}

resource "aws_lb_target_group" "tg" {
  name     = "ha-webapp-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  
}


resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
