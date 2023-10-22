####################################################
##   System
####################################################
variable "system" {
    type = string
    description = "Your system name."
}
variable "env" {
    type = string
    description = "Infrastructure environments, e.g. dev,stg,prd…"
}
variable "aws_credentials_file" {
    type = list(string)
    description = "AWS CLI credential file path."
}
variable "aws_profile" {
    type = string
    description = "Profile used with AWS CLI."
}
variable "domain" {
    type = string
    description = "Your system domain."
}

####################################################
##   VPC
####################################################
variable "aws_az" {
    type = list(string)
    description = "Availability zone used by your system."
}
variable "cidr_vpc" {
    type = string
    description = "CIDR of VPC."
}
variable "cidr_private" {
    type = list(string)
    description = "CIDR of private subnet for ECS."
}
variable "cidr_private_rds" {
    type = list(string)
    description = "CIDR of private subnet used by RDS and ElastiCache."
}
variable "cidr_public" {
    type = list(string)
    description = "CIDR of public subnet."
}

variable "allow_inbound_ips" {
    type = list(string)
    description = "IP list allowing access to limited areas."
}

####################################################
##   Aurora RDS
####################################################
variable "rds_instance_class" {
    type = string
    description = "https://aws.amazon.com/jp/rds/instance-types/"
}
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


####################################################
##   ECS
####################################################
variable "conainer_insight_enabled" {
    type = bool
}

####################################################
##   Deploy
####################################################
variable "webapp_repo_name" {
    type = string
    description = "Your webapp repository name."
}

variable "webapp_branch_name" {
    type = string
    description = "Your webapp branch name."
}

variable "taskdef_temp_path" {
    type = string
    description = "Your taskdef template path."
}

variable "appspec_temp_path" {
    type = string
    description = "Your appspec template path."
}