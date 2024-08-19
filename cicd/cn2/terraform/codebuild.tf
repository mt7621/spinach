resource "aws_codebuild_project" "codebuild" {
  name = "wsc2024-cbd"
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type = "LOCAL"
    modes = [
      "LOCAL_DOCKER_LAYER_CACHE"
    ]
  }

  source {
    type = "CODEPIPELINE"
    buildspec = "buildspec.yaml"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    type = "LINUX_CONTAINER"
    image = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    privileged_mode = true
  }

  depends_on = [
    aws_codecommit_repository.codecommit
  ]
}