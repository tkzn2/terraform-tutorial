## account ID
data "aws_caller_identity" "current" {}


## ecr repository
resource "aws_ecr_repository" "web" {
    name = var.ecr_repo_web_name
    force_delete = true
}

resource "aws_ecr_repository" "app" {
    name = var.ecr_repo_app_name
    force_delete = true
}

## dummy image for first deploy
resource "null_resource" "docker_push" {
    depends_on = [aws_ecr_repository.web]

    provisioner "local-exec" {
        command = "aws ecr get-login-password --profile ${var.aws_profile} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com"
    }
    provisioner "local-exec" {
        command = "docker build -t ${var.ecr_repo_web_name} -f ../../modules/ecr/files/web/Dockerfile ../../"
    }
    provisioner "local-exec" {
        command = "docker build -t ${var.ecr_repo_app_name} -f ../../modules/ecr/files/app/Dockerfile ../../"
    }
    provisioner "local-exec" {
        command = "docker tag ${var.ecr_repo_web_name}:latest ${aws_ecr_repository.web.repository_url}:latest"
    }
    provisioner "local-exec" {
        command = "docker tag ${var.ecr_repo_app_name}:latest ${aws_ecr_repository.app.repository_url}:latest"
    }
    provisioner "local-exec" {
        command = "docker push ${aws_ecr_repository.web.repository_url}:latest"
    }
    provisioner "local-exec" {
        command = "docker push ${aws_ecr_repository.app.repository_url}:latest"
    }

}