## AZ
## Usage：data.aws_availability_zones.az.names
data "aws_availability_zones" "az" {
    state = "available"
}

## local variables
locals {
    nat_count = length(var.cidr_public)
}

## vpc
resource "aws_vpc" "vpc" {
    cidr_block = var.cidr_vpc

    tags = {
        Name = "${var.name_prefix}-vpc"
    }
}

## private subnet
resource "aws_subnet" "private" {
    count = length(var.cidr_private)
    vpc_id = aws_vpc.vpc.id
    cidr_block = element(var.cidr_private, count.index)
    availability_zone = element(var.aws_az, count.index)

    tags = {
        Name = "${var.name_prefix}-subnet-private${count.index + 1}"
    }
}

## private subnet for rds
resource "aws_subnet" "private_rds" {
    count = length(var.cidr_private_rds)
    vpc_id = aws_vpc.vpc.id
    cidr_block = element(var.cidr_private_rds, count.index)
    availability_zone = element(var.aws_az, count.index)

    tags = {
        Name = "${var.name_prefix}-subnet-private-rds${count.index + 1}"
    }
}

## public subnet
resource "aws_subnet" "public" {
    count = length(var.cidr_public)
    vpc_id = aws_vpc.vpc.id
    cidr_block = element(var.cidr_public, count.index)
    availability_zone = element(var.aws_az, count.index)

    tags = {
        Name = "${var.name_prefix}-subnet-public${count.index + 1}"
    }
}

## EIP for nat
resource "aws_eip" "eip" {
    count = local.nat_count
    domain = "vpc"

    tags = {
        Name = "${var.name_prefix}-eip${count.index + 1}"
    }
}

## igw
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id

    tags = {
        Name = "${var.name_prefix}-igw"
    }
}

## nat
resource "aws_nat_gateway" "nat" {
    count = local.nat_count
    allocation_id = element(aws_eip.eip.*.id, count.index)
    subnet_id = element(aws_subnet.public.*.id, count.index)

    tags = {
        Name = "${var.name_prefix}-nat${count.index + 1}"
    }
}

## route table for private subnets
resource "aws_route_table" "private" {
    count = length(var.cidr_public)
    vpc_id = aws_vpc.vpc.id

    tags = {
        Name = "${var.name_prefix}-rt-private${count.index + 1}"
    }
}

## route table for public subnets
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.vpc.id

    tags = {
        Name = "${var.name_prefix}-rt-public"
    }
}

## routing private to internet via nat
resource "aws_route" "private" {
    count = length(var.cidr_public)
    route_table_id = element(aws_route_table.private.*.id, count.index)
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.nat.*.id, count.index)
}

## routing public
resource "aws_route" "public" {
    route_table_id = aws_route_table.public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
}

## route table assoc at private subnets
resource "aws_route_table_association" "private" {
    count = length(var.cidr_private)
    subnet_id = element(aws_subnet.private.*.id, count.index)
    route_table_id = element(aws_route_table.private.*.id, count.index)
}

## route table assoc at public subnets
resource "aws_route_table_association" "public" {
    count = length(var.cidr_public)
    subnet_id = element(aws_subnet.public.*.id, count.index)
    route_table_id = aws_route_table.public.id
}