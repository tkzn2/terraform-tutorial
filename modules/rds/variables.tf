variable "name_prefix" {}
variable "subnets" {}
variable "security_groups" {}
variable "aws_az" {}
variable "skip_final_snapshot" {
    type = bool
}
variable "apply_immediately" {
    type = bool
}
variable "deletion_protection" {
    type = bool
    description = "If this parameter is set to true, terraform cannot destroy this resource."
}
variable "instance_class" {
    description = "https://aws.amazon.com/jp/rds/instance-types/"
}