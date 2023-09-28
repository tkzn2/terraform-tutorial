## subnet group
resource "aws_db_subnet_group" "rds" {
    name = "${var.name_prefix}-subnet-group-aurora"
    subnet_ids = [for subnet in var.subnets : subnet.id]

    tags = {
        Name = "${var.name_prefix}-subnet-group-aurora"
    }
}

## aurora mysql
resource "aws_rds_cluster" "rds" {
    cluster_identifier = "${var.name_prefix}-aurora-rds"
    engine = "aurora-mysql"
    engine_version = "8.0.mysql_aurora.3.04.0"
    availability_zones = var.aws_az
    db_subnet_group_name = aws_db_subnet_group.rds.name
    vpc_security_group_ids = [for sg in var.security_groups : sg.id]
    storage_type = ""
    manage_master_user_password = true
    master_username = "test"

    skip_final_snapshot = var.skip_final_snapshot
    apply_immediately = var.apply_immediately
    deletion_protection = var.deletion_protection

    timeouts {
        create = "30m"
        update = "30m"
        delete = "1h"
    }

    tags = {
        Name = "${var.name_prefix}-aurora-cluster"
    }
}

## aurora instance
resource "aws_rds_cluster_instance" "rds" {
    count = 1

    cluster_identifier = aws_rds_cluster.rds.id
    identifier = "${var.name_prefix}-aurora-instance-${count.index + 1}"

    engine = aws_rds_cluster.rds.engine
    engine_version = aws_rds_cluster.rds.engine_version
    instance_class = var.instance_class
    db_subnet_group_name    = aws_db_subnet_group.rds.name

    publicly_accessible = false

    timeouts {
        create = "10m"
        update = "10m"
        delete = "1h"
    }

    tags = {
        Name = "${var.name_prefix}-aurora-instance-${count.index + 1}"
    }
}