## data policy assume role for ecs task
data "aws_iam_policy_document" "ecs_web_task_assume_role" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type    = "Service"
            identifiers =["ecs-tasks.amazonaws.com"]
        }
    }
}

## data policy assume role for ecs task ssm
data "aws_iam_policy_document" "ecs_task_role_ssmmessages" {
    version = "2012-10-17"
    statement {
        actions = [
            "ssmmessages:CreateControlChannel",
            "ssmmessages:CreateDataChannel",
            "ssmmessages:OpenControlChannel",
            "ssmmessages:OpenDataChannel"
        ]
        resources = ["*"]
    }
}

## iam role for web task role
resource "aws_iam_role" "web_task_role" {
    name = "ecs_web_task_role"
    assume_role_policy = data.aws_iam_policy_document.ecs_web_task_assume_role.json
}

resource "aws_iam_policy" "ecs_task_role_ssmmessages" {
    name_prefix = "ecs_task_ssmmessages"
    policy = data.aws_iam_policy_document.ecs_task_role_ssmmessages.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_ssmmessages" {
    role = aws_iam_role.web_task_role.name
    policy_arn = aws_iam_policy.ecs_task_role_ssmmessages.arn
}


resource "aws_iam_role" "web_task_execute_role" {
    name = "ecs_web_task_execute_role"
    assume_role_policy = data.aws_iam_policy_document.ecs_web_task_assume_role.json
}

resource "aws_iam_role_policy_attachment" "web_task_execute_role_execution_role_policy" {
  role = aws_iam_role.web_task_execute_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}