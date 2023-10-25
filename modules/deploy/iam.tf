## code pipeline role
data "aws_iam_policy_document" "assume_role_pipeline" {
    statement {
        effect = "Allow"
        actions = ["sts:AssumeRole"]
        principals {
            type = "Service"
            identifiers = ["codepipeline.amazonaws.com"]
        }
    }
}

resource "aws_iam_role" "codepipeline" {
    name = "${var.name_prefix}-codepipeline-webapp-role"
    assume_role_policy = data.aws_iam_policy_document.assume_role_pipeline.json
}

data "aws_iam_policy_document" "codepipeline" {
    statement {
        effect = "Allow"
        actions = [
            "codebuild:BatchGetBuilds",
            "codebuild:StartBuild",
            "codebuild:BatchGetBuildBatches",
            "codebuild:StartBuildBatch"
        ]
        resources = ["*"]
    }
    statement {
        effect = "Allow"
        actions = [
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:GetBucketVersioning",
            "s3:PutObject",
            "s3:PutObjectVersionAcl",
            "s4:PutObjectAcl"
        ]
        resources = [
            aws_s3_bucket.pipeline_artifact.arn,
            "${aws_s3_bucket.pipeline_artifact.arn}/*"
        ]
    }

    statement {
        effect = "Allow"
        actions = [
            "codestar-connections:UseConnection"
        ]
        resources = [
            aws_codestarconnections_connection.webapp.arn
        ]
    }

    statement {
        effect = "Allow"
        actions = [
            "codedeploy:CreateDeployment",
            "codedeploy:GetDeployment",
            "codedeploy:GetApplication",
            "codedeploy:GetApplicationRevision",
            "codedeploy:RegisterApplicationRevision",
            "codedeploy:GetDeploymentConfig",
            "ecs:RegisterTaskDefinition",
            "ecs:TagResource"
        ]
        resources = ["*"]
    }

    statement {
        effect = "Allow"
        actions = [
            "iam:PassRole"
        ]
        resources = ["*"]
    }
}

resource "aws_iam_role_policy" "codepipeline" {
    name = "${var.name_prefix}-codepipeline-webapp-policy"
    role = aws_iam_role.codepipeline.name
    policy = data.aws_iam_policy_document.codepipeline.json
}

## code build role
data "aws_iam_policy_document" "assume_role_codebuild" {
    statement {
        effect = "Allow"
        actions = ["sts:AssumeRole"]
        principals {
            type = "Service"
            identifiers = ["codebuild.amazonaws.com"]
        }
    }
}

resource "aws_iam_role" "codebuild" {
    name = "${var.name_prefix}-codebuild-webapp-role"
    assume_role_policy = data.aws_iam_policy_document.assume_role_codebuild.json
}

data "aws_iam_policy_document" "codebuild" {
    statement {
        effect = "Allow"
        actions = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ]
        resources = ["*"]
    }
    statement {
        effect = "Allow"
        actions = [
            "ecr:BatchCheckLayerAvailability",
            "ecr:CompleteLayerUpload",
            "ecr:GetAuthorizationToken",
            "ecr:InitiateLayerUpload",
            "ecr:PutImage",
            "ecr:UploadLayerPart",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "ecr:BatchCheckLayerAvailability"
        ]
        resources = ["*"]
    }
    statement {
        effect = "Allow"
        actions = [
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:GetBucketVersioning",
            "s3:PutObject",
            "s3:PutObjectVersionAcl",
            "s3:PutObjectAcl"
        ]
        resources = [
            aws_s3_bucket.pipeline_artifact.arn,
            "${aws_s3_bucket.pipeline_artifact.arn}/*"
        ]
    }
    statement {
        effect = "Allow"
        actions = [
            "codebuild:CreateReportGroup",
            "codebuild:CreateReport",
            "codebuild:UpdateReport",
            "codebuild:BatchPutTestCases",
            "codebuild:BatchPutCodeCoverages",
            "codebuild:StartBuild",
            "codebuild:StopBuild",
            "codebuild:RetryBuild"
        ]
        resources = ["*"]
    }
    statement {
        effect = "Allow"
        actions = [
            "codestar-connections:UseConnection"
        ]
        resources = [
            aws_codestarconnections_connection.webapp.arn
        ]
    }
}

resource "aws_iam_role_policy" "codebuild" {
    name = "${var.name_prefix}-codebuild-webapp-policy"
    role = aws_iam_role.codebuild.name
    policy = data.aws_iam_policy_document.codebuild.json
}

## code deploy role
data "aws_iam_policy_document" "assume_role_codedeploy" {
    statement {
        effect = "Allow"
        actions = ["sts:AssumeRole"]
        principals {
            type = "Service"
            identifiers = ["codedeploy.amazonaws.com"]
        }
    }
}

resource "aws_iam_role" "codedeploy" {
    name = "${var.name_prefix}-codedeploy-webapp-role"
    assume_role_policy = data.aws_iam_policy_document.assume_role_codedeploy.json
}

resource "aws_iam_role_policy_attachment" "codedeploy" {
    role = aws_iam_role.codedeploy.name
    policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}