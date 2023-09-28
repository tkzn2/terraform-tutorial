## taskdef from tftpl
data "template_file" "taskdef_application" {
    template = file(var.task_definition_application)

    vars = {
        container_name_web = "nginx"
        image_web = var.ecr_repo_web.repository_url
        container_name_app = "php"
        image_app = var.ecr_repo_app.repository_url
        logs_group_application = var.log_group_name_application
        logs_stream_prefix_web = "web"
        logs_stream_prefix_app = "app"
    }
}

## taskdef
resource "aws_ecs_task_definition" "web" {
    family = "${var.name_prefix}-taskdef-web"
    requires_compatibilities = ["FARGATE"]
    network_mode = "awsvpc"
    cpu = 256
    memory = 512
    task_role_arn = var.web_task_role.arn
    execution_role_arn = var.web_task_execute_role.arn
    container_definitions = data.template_file.taskdef_application.rendered

}

resource "aws_ecs_cluster" "web" {
    name = "${var.name_prefix}-cluster-web"
}

resource "aws_ecs_service" "web" {
    name = "${var.name_prefix}-service-web"
    cluster = aws_ecs_cluster.web.id
    task_definition = aws_ecs_task_definition.web.arn
    desired_count = 1
    launch_type = "FARGATE"
    depends_on = [var.target_group]
    enable_execute_command = true

    network_configuration {
        subnets = [for subnet in var.subnets : subnet.id]
        security_groups = [for sg in var.security_groups : sg.id]
    }

    load_balancer {
        target_group_arn = var.target_group.arn
        container_name = "nginx"
        container_port = "80"
    }

    deployment_controller {
        type = "CODE_DEPLOY"
    }

    lifecycle {
        ignore_changes = [
            desired_count,
            load_balancer,
            task_definition
        ]
    }
}