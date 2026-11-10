
resource "aws_lb_target_group" "utc_target_group" {
  name        = "utc-target-group"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.sch-vpc.id
  protocol_version = "HTTP1"

  health_check {
    enabled  = true
    protocol = "HTTP"
    path     = "/"
    matcher  = "200"
  }

  tags = {
    Name = "utc-target-group"
    env  = "dev"
    team = "config management"
  }
}


resource "aws_lb_target_group_attachment" "app_server_1" {
  target_group_arn = aws_lb_target_group.utc_target_group.arn
  target_id        = aws_instance.appserver_1a.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "app_server_2" {
  target_group_arn = aws_lb_target_group.utc_target_group.arn
  target_id        = aws_instance.appserver_1b.id
  port             = 80
}
