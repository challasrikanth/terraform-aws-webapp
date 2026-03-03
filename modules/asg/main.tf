resource "aws_launch_template" "lt" {
  name = "webapp-template"

  image_id      = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = [ aws_security_group.ec2_sg.id ]

  user_data = base64encode(<<-EOF
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h2>Highly Available WebApp - ASG EC2</h2>" > /var/www/html/index.html
EOF
)
}

resource "aws_autoscaling_group" "asg" {
  desired_capacity    = 2
  max_size            = 4
  min_size            = 2
  vpc_zone_identifier = var.private_subnets

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  target_group_arns = [var.target_group_arn]
}


resource "aws_security_group" "ec2_sg" {
  name        = "webapp-ec2-sg"
  description = "Allow HTTP from ALB; optional SSH"
  vpc_id      = var.vpc_id

  # HTTP from ALB only
  ingress {
    description              = "HTTP from ALB SG"
    from_port                = 80
    to_port                  = 80
    protocol                 = "tcp"
    security_groups          = [var.alb_sg_id] 
   
  }

  egress {
    description = "Allow all egress (updates via NAT)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
