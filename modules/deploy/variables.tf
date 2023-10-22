variable "name_prefix" {
    type = string
    description = "Your system name."
}

variable "webapp_repo_name" {
    type = string
    description = "Your webapp repository name."
}

variable "webapp_branch_name" {
    type = string
    description = "Your webapp branch name."
}

variable "listner_web_prd_arn" {
    type = string
    description = "Your webapp ALB Listner arn."
}

variable "listner_web_test_arn" {
    type = string
    description = "Your webapp ALB Listner arn."
}

variable "tg_web_blue_name" {
    type = string
    description = "Your webapp target group name."
}

variable "tg_web_green_name" {
    type = string
    description = "Your webapp target group name."
}

variable "ecs_cluster_name" {
    type = string
    description = "Your ECS cluster name."
}

variable "ecs_service_name" {
    type = string
    description = "Your ECS service name."
}

variable "taskdef_temp_path" {
    type = string
    description = "Your taskdef template path."

}

variable "appspec_temp_path" {
    type = string
    description = "Your appspec template path."
}