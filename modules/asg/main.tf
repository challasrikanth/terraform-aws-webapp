resource "aws_launch_template" "lt" {
  name = "webapp-template"

  image_id      = var.ami
  instance_type = var.instance_type

  user_data = base64encode(<<-EOF
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Welcome to Highly Available Web Application</h1>" > /var/www/html/index.html
EOF
)
}

resource "aws_autoscaling_group" "asg" {
  vpc_zone_identifier = var.subnet_ids
  desired_capacity    = 2
  max_size            = 4
  min_size            = 2

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  target_group_arns = [var.target_group_arn]
}