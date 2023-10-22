## s3 for codepipeline artifacts
resource "aws_s3_bucket" "pipeline_artifact" {
    bucket = local.bucket_name
}

resource "aws_s3_bucket_ownership_controls" "pipeline_artifact" {
    bucket = aws_s3_bucket.pipeline_artifact.id
    rule {
        object_ownership = "BucketOwnerEnforced"
    }
}