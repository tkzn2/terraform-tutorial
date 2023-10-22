## code build project
resource "aws_codebuild_project" "web" {
    name = "${var.name_prefix}-codebuild-web"
    description = "CodeBuild for web application."
    service_role = aws_iam_role.codebuild.arn
    artifacts {
        type = "CODEPIPELINE"
        name = "BuildArtifact"
    }
    environment {
        compute_type = "BUILD_GENERAL1_SMALL"
        image = "aws/codebuild/standard:5.0"
        type = "LINUX_CONTAINER"
        image_pull_credentials_type = "CODEBUILD"
        privileged_mode = false
    }
    source {
        type = "CODEPIPELINE"
        buildspec = "buildspec.yml"
    }
    build_batch_config {
        service_role = aws_iam_role.codebuild.arn
        combine_artifacts = true
        timeout_in_mins = 30
        restrictions {
            maximum_builds_allowed = 100
            compute_types_allowed = ["BUILD_GENERAL1_SMALL"]
        }
    }
}