resource "aws_alb" "alb" {
  name= "ha-webapp-alb"
  load_balancer_type = "application"
  subnets = var.public_subnets
  security_groups = [ aws_security_group.alb_sg.id ]

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



resource "aws_security_group" "alb_sg" {
  name = "webapp-alb-sg"
  description = "allow http from the internet"


  ingress  {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = var.alb_cidr
  }
  egress  {
  from_port = 80
  to_port = 80
  protocol = "-1"
  cidr_blocks = var.alb_cidr
}

}