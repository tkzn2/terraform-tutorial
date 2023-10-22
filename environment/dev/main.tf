terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "5.17.0"
        }
    }
}

provider "aws" {
    region = "ap-northeast-1"
    shared_credentials_files = var.aws_credentials_file
    profile = var.aws_profile

    default_tags {
        tags = {
            CostTag = "${var.system}-${var.env}"
            System = "${var.system}"
            Env = "${var.env}"
        }
    }
}

locals {
    log_group_name_application = "/ecs/${var.system}/${var.env}/application"
}

module "vpc" {
    source = "../../modules/vpc"
    name_prefix = "${var.system}-${var.env}"
    aws_az = var.aws_az
    cidr_vpc = var.cidr_vpc
    cidr_private = var.cidr_private
    cidr_public = var.cidr_public
    cidr_private_rds = var.cidr_private_rds
}

module "iam" {
    source = "../../modules/iam"
}

module "sg" {
    source = "../../modules/securitygroup"
    name_prefix = "${var.system}-${var.env}"
    vpc_id = module.vpc.vpc_id
    allow_inbound_ips = var.allow_inbound_ips
    cidr_vpc = var.cidr_vpc
}

module "alb" {
    source = "../../modules/loadbalancer"
    name_prefix = "${var.system}-${var.env}"
    vpc_id = module.vpc.vpc_id
    subnets = module.vpc.subnet_public
    security_groups = [module.sg.sg_alb]
    domain = var.domain
}

module "ecs" {
    source = "../../modules/ecs"
    system = var.system
    env = var.env
    name_prefix = "${var.system}-${var.env}"
    subnets = module.vpc.subnet_private
    security_groups = [module.sg.sg_ecs]
    target_group = module.alb.target_group_main
    web_task_role = module.iam.web_task_role
    web_task_execute_role = module.iam.web_task_execute_role
    task_definition_application = "../../template/taskdef/taskdef.json.tftpl"
    ecr_repo_web = module.ecr.ecr_repo_web
    ecr_repo_app = module.ecr.ecr_repo_app
    log_group_name_application = local.log_group_name_application
    conainer_insight_enabled = var.conainer_insight_enabled
}

module "route53" {
    source = "../../modules/route53"
    domain = var.domain
    alb = module.alb.alb_main
}

# module "rds" {
#     source = "../../modules/rds"
#     name_prefix = "${var.system}-${var.env}"
#     subnets = module.vpc.subnet_private_rds
#     security_groups = [module.sg.sg_rds]
#     aws_az = var.aws_az
#     skip_final_snapshot = var.skip_final_snapshot
#     apply_immediately = var.apply_immediately
#     deletion_protection = var.deletion_protection
#     instance_class = var.rds_instance_class
# }

module "ecr" {
    source = "../../modules/ecr"
    ecr_repo_web_name = "web"
    ecr_repo_app_name = "app"
    aws_profile = var.aws_profile
}

module "cloudwatch" {
    source = "../../modules/cloudwatch"
    log_group_name_application = local.log_group_name_application
}

module "deploy" {
    source = "../../modules/deploy"
    name_prefix = "${var.system}-${var.env}"
    webapp_repo_name = var.webapp_repo_name
    webapp_branch_name = var.webapp_branch_name
    listner_web_prd_arn = module.alb.listner_blue.arn
    listner_web_test_arn = module.alb.listner_green.arn
    tg_web_blue_name = module.alb.target_group_main.name
    tg_web_green_name = module.alb.target_group_test.name
    ecs_cluster_name = module.ecs.ecs_cluster_web.name
    ecs_service_name = module.ecs.ecs_service_web.name
    taskdef_temp_path = var.taskdef_temp_path
    appspec_temp_path = var.appspec_temp_path
}