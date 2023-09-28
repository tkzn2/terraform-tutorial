## data acm certificate
data "aws_acm_certificate" "acm" {
  domain = var.domain
}

## alb
resource "aws_lb" "main" {
    name = "${var.name_prefix}-alb-main"
    load_balancer_type = "application"
    security_groups    = [for sg in var.security_groups : sg.id]
    subnets            = [for subnet in var.subnets : subnet.id]

    tags = {
        Name = "${var.name_prefix}-alb-main"
    }
}

## alb target group BLUE
resource "aws_lb_target_group" "blue" {
    name = "${var.name_prefix}-target-ecs-blue"
    vpc_id = var.vpc_id

    port = 80
    protocol = "HTTP"
    target_type = "ip"
    
    health_check {
        port = 80
        path = "/"
    }

    lifecycle {
        create_before_destroy = true
    }
}

## alb listner http
resource "aws_lb_listener" "http" {
    port = "80"
    protocol = "HTTP"

    load_balancer_arn = aws_lb.main.arn

    # "ok"
    default_action {
        type = "fixed-response"

        fixed_response {
            content_type = "text/plain"
            status_code = "200"
            message_body = "ok"
        }
    }
}

# alb listner rule http
resource "aws_lb_listener_rule" "http" {
    listener_arn = aws_lb_listener.http.arn

    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.blue.arn
    }

    condition {
        path_pattern {
            values = ["*"]
        }
    }
}


# alb listner rule http
resource "aws_lb_listener_rule" "http_to_https" {
    listener_arn = aws_lb_listener.http.arn
    priority = 100

    action {
        type = "redirect"
        redirect {
            port = "443"
            protocol = "HTTPS"
            status_code = "HTTP_302"
        }
    }

    condition {
        host_header {
            values = [var.domain]
        }
    }
}

## alb listner https
resource "aws_lb_listener" "https_blue" {
    port = "443"
    protocol = "HTTPS"

    load_balancer_arn = aws_lb.main.arn

    certificate_arn = data.aws_acm_certificate.acm.arn

    # "ok"
    default_action {
        type = "fixed-response"

        fixed_response {
            content_type = "text/plain"
            status_code = "200"
            message_body = "ok"
        }
    }
}

# alb listner rule https at BLUE
resource "aws_lb_listener_rule" "https_blue" {
    listener_arn = aws_lb_listener.https_blue.arn

    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.blue.arn
    }

    condition {
        path_pattern {
            values = ["*"]
        }
    }

    lifecycle {
        ignore_changes = [
            action
        ]
    }
}

## alb target group GREEN
resource "aws_lb_target_group" "green" {
    name = "${var.name_prefix}-target-ecs-green"
    vpc_id = var.vpc_id

    port = 80
    protocol = "HTTP"
    target_type = "ip"
    
    health_check {
        port = 80
        path = "/"
    }

    lifecycle {
        create_before_destroy = true
    }
}

## alb listner https
resource "aws_lb_listener" "https_green" {
    port = "11443"
    protocol = "HTTPS"

    load_balancer_arn = aws_lb.main.arn

    certificate_arn = data.aws_acm_certificate.acm.arn

    # "ok"
    default_action {
        type = "fixed-response"

        fixed_response {
            content_type = "text/plain"
            status_code = "200"
            message_body = "ok"
        }
    }
}

# alb listner rule https
resource "aws_lb_listener_rule" "https_green" {
    listener_arn = aws_lb_listener.https_green.arn

    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.green.arn
    }

    condition {
        path_pattern {
            values = ["*"]
        }
    }

    lifecycle {
        ignore_changes = [
            action
        ]
    }
}