## code deploy
resource "aws_codedeploy_app" "web" {
    name = "${var.name_prefix}-codedeploy-web"
    compute_platform = "ECS"
}

resource "aws_codedeploy_deployment_group" "web" {
    deployment_group_name = "${var.name_prefix}-codedeploy-group-web"
    app_name = aws_codedeploy_app.web.name
    service_role_arn = aws_iam_role.codedeploy.arn
    deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
    deployment_style {
        deployment_type = "BLUE_GREEN"
        deployment_option = "WITH_TRAFFIC_CONTROL"
    }
    blue_green_deployment_config {
        terminate_blue_instances_on_deployment_success {
            action = "TERMINATE"
            termination_wait_time_in_minutes = 20
        }
        deployment_ready_option {
            action_on_timeout = "STOP_DEPLOYMENT"
            wait_time_in_minutes = 10
        }
    }
    ecs_service {
        cluster_name = var.ecs_cluster_name
        service_name = var.ecs_service_name
    }
    load_balancer_info {
        target_group_pair_info {
            prod_traffic_route {
                listener_arns = [var.listner_web_prd_arn]
            }
            test_traffic_route {
                listener_arns = [var.listner_web_test_arn]
            }
            target_group {
                name = var.tg_web_blue_name
            }
            target_group {
                name = var.tg_web_green_name
            }
        }
    }
    auto_rollback_configuration {
        enabled = true
        events = ["DEPLOYMENT_FAILURE"]
    }
}