resource "aws_cloudwatch_log_group" "web" {
    name = var.log_group_name_application
}