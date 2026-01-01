# modules/alb/main.tf - SIMPLIFIED VERSION

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.web_sg_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = merge(var.tags, {
    Name = "${var.project_name}-alb-${var.environment}"
  })
}

# Target Group
resource "aws_lb_target_group" "main" {
  name     = "${var.project_name}-tg-${var.environment}"
  port     = var.web_app_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    interval            = 30
    path                = var.health_check_path
    port                = var.web_app_port
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-299"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-tg-${var.environment}"
  })
}

# HTTP Listener - ONLY THIS, NO HTTPS
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"  # Just forward, no redirect
    target_group_arn = aws_lb_target_group.main.arn
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-http-listener-${var.environment}"
  })
}

# REMOVE THE ENTIRE HTTPS LISTENER BLOCK
# resource "aws_lb_listener" "https" { ... }