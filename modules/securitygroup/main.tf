## alb
resource "aws_security_group" "alb" {
    vpc_id = var.vpc_id

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    tags = {
        Name = "${var.name_prefix}-sg-alb"
    }
}

## allow port80 alb
resource "aws_security_group_rule" "http" {
    security_group_id = aws_security_group.alb.id
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = var.allow_inbound_ips
}

## allow port443 alb
resource "aws_security_group_rule" "https" {
    security_group_id = aws_security_group.alb.id
    type = "ingress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = var.allow_inbound_ips
}

## allow port443 alb
resource "aws_security_group_rule" "https_green" {
    security_group_id = aws_security_group.alb.id
    type = "ingress"
    from_port = 11443
    to_port = 11443
    protocol = "tcp"
    cidr_blocks = var.allow_inbound_ips
}

## ecs
resource "aws_security_group" "ecs" {
    vpc_id = var.vpc_id

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    tags = {
        Name = "${var.name_prefix}-sg-ecs"
    }
}

## allow all trafic from vpc
resource "aws_security_group_rule" "ecs" {
    security_group_id = aws_security_group.ecs.id
    type = "ingress"
    from_port = 0
    to_port = 0
    protocol = "all"
    cidr_blocks = [var.cidr_vpc]
}

## rds
resource "aws_security_group" "rds" {
    vpc_id = var.vpc_id

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    tags = {
        Name = "${var.name_prefix}-sg-rds"
    }
}

## allow all trafic from vpc
resource "aws_security_group_rule" "rds" {
    security_group_id = aws_security_group.rds.id
    type = "ingress"
    from_port = 0
    to_port = 0
    protocol = "all"
    cidr_blocks = [var.cidr_vpc]
}
