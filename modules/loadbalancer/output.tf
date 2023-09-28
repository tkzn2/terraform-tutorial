output "target_group_main" {
    value = aws_lb_target_group.blue
}

output "alb_main" {
    value = aws_lb.main
}
