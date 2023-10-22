output "target_group_main" {
    value = aws_lb_target_group.blue
}

output "target_group_test" {
    value = aws_lb_target_group.green
}

output "alb_main" {
    value = aws_lb.main
}

output "listner_blue" {
    value = aws_lb_listener.https_blue
}

output "listner_green" {
    value = aws_lb_listener.https_green
}