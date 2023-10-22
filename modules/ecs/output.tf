output "ecs_cluster_web" {
    value = aws_ecs_cluster.web
}

output "ecs_service_web" {
    value = aws_ecs_service.web
}