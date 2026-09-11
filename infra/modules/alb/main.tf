resource "aws_lb" "plane_alb" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.plane_sg.id]
  subnets            = var.public_subnets_ids

  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-alb"
  }
}

resource "aws_security_group" "plane_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "Security group for ${var.project_name} ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow all HTTP inbound traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow all HTTPS inbound traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

resource "aws_lb_target_group" "plane_web_tg" {
  name        = "${var.project_name}-web-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = "${var.project_name}-web-tg"
  }
}

resource "aws_lb_target_group" "plane_admin_tg" {
  name        = "${var.project_name}-admin-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/god-mode/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = "${var.project_name}-admin-tg"
  }
}

resource "aws_lb_target_group" "plane_space_tg" {
  name        = "${var.project_name}-space-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/spaces/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = "${var.project_name}-space-tg"
  }
}

resource "aws_lb_target_group" "plane_api_tg" {
  name        = "${var.project_name}-api-tg"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/api/users/session/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = "${var.project_name}-api-tg"
  }
}

resource "aws_lb_target_group" "plane_live_tg" {
  name        = "${var.project_name}-live-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/live/"
    protocol            = "HTTP"
    matcher             = "200-404"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = "${var.project_name}-live-tg"
  }
}


resource "aws_lb_listener_rule" "plane_admin_rule" {
  listener_arn = aws_lb_listener.plane_https_listener.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.plane_admin_tg.arn
  }

  condition {
    path_pattern {
      values = ["/god-mode/*"]
    }
  }
}

resource "aws_lb_listener_rule" "god_mode_redirect" {
  listener_arn = aws_lb_listener.plane_https_listener.arn
  priority     = 9

  action {
    type = "redirect"

    redirect {
      protocol    = "HTTPS"
      host        = "#{host}"
      path        = "/god-mode/"
      query       = "#{query}"
      status_code = "HTTP_301"
    }
  }

  condition {
    path_pattern {
      values = ["/god-mode"]
    }
  }
}

resource "aws_lb_listener_rule" "plane_space_rule" {
  listener_arn = aws_lb_listener.plane_https_listener.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.plane_space_tg.arn
  }

  condition {
    path_pattern {
      values = ["/spaces/*", "/spaces"]
    }
  }
}

resource "aws_lb_listener_rule" "plane_api_rule" {
  listener_arn = aws_lb_listener.plane_https_listener.arn
  priority     = 30

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.plane_api_tg.arn
  }

  condition {
    path_pattern {
      values = ["/api/*", "/api"]
    }
  }
}

resource "aws_lb_listener_rule" "plane_auth_rule" {
  listener_arn = aws_lb_listener.plane_https_listener.arn
  priority     = 40

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.plane_api_tg.arn
  }

  condition {
    path_pattern {
      values = ["/auth/*", "/auth"]
    }
  }
}

resource "aws_lb_listener_rule" "plane_live_rule" {
  listener_arn = aws_lb_listener.plane_https_listener.arn
  priority     = 50

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.plane_live_tg.arn
  }

  condition {
    path_pattern {
      values = ["/live/*", "/live"]
    }
  }
}
resource "aws_lb_listener" "plane_http_listener" {
  load_balancer_arn = aws_lb.plane_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "plane_https_listener" {
  load_balancer_arn = aws_lb.plane_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.plane_web_tg.arn
  }
}