## pipeline web
resource "aws_codepipeline" "web" {
    name = "${var.name_prefix}-pipeline-web"
    role_arn = aws_iam_role.codepipeline.arn
    artifact_store {
        location = local.bucket_name
        type = "S3"
    }
    stage {
        name = "Source"
        action {
            name = "Source"
            category = "Source"
            owner = "AWS"
            provider = "CodeStarSourceConnection"
            version = "1"
            output_artifacts = ["Source"]
            configuration = {
                ConnectionArn = aws_codestarconnections_connection.webapp.arn
                FullRepositoryId = var.webapp_repo_name
                BranchName = var.webapp_branch_name
                OutputArtifactFormat = "CODEBUILD_CLONE_REF"
            }
        }
    }
    stage {
        name = "Build"
        action {
            name = "Build"
            category = "Build"
            owner = "AWS"
            provider = "CodeBuild"
            version = "1"
            input_artifacts = ["Source"]
            output_artifacts = ["BuildArtifact"]
            configuration = {
                BatchEnabled = true
                CombineArtifacts = true
                ProjectName = aws_codebuild_project.web.name
            }
        }
    }
    stage {
        name = "Deploy"
        action {
            name = "Deploy"
            category = "Deploy"
            owner = "AWS"
            provider = "CodeDeployToECS"
            version = "1"
            input_artifacts = ["BuildArtifact"]
            configuration = {
                ApplicationName = aws_codedeploy_app.web.name
                DeploymentGroupName = aws_codedeploy_deployment_group.web.deployment_group_name
                TaskDefinitionTemplateArtifact = "BuildArtifact"
                TaskDefinitionTemplatePath = var.taskdef_temp_path
                AppSpecTemplateArtifact = "BuildArtifact"
                AppSpecTemplatePath = var.appspec_temp_path
            }
        }
    }
}

## codestart connection
resource "aws_codestarconnections_connection" "webapp" {
    provider_type = "GitHub"
    name = "${var.name_prefix}-connection-webapp"
}