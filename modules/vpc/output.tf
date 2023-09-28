output "vpc_id" {
    value = aws_vpc.vpc.id
}

output "subnet_private" {
    value = aws_subnet.private
}

output "subnet_private_rds" {
    value = aws_subnet.private_rds
}

output "subnet_public" {
    value = aws_subnet.public
}