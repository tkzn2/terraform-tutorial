output "sg_alb" {
    value = aws_security_group.alb
}

output "sg_ecs" {
    value = aws_security_group.ecs
}

output "sg_rds" {
    value = aws_security_group.rds
}