output "ecr_repo_web" {
    value = aws_ecr_repository.web
}

output "ecr_repo_app" {
    value = aws_ecr_repository.app
}
