resource "aws_s3_bucket" "codepipeline" {
  bucket = "wsi-tf-codebuild-wefwefwefwef"
}

resource "aws_s3_bucket_acl" "codebuild" {
  bucket = aws_s3_bucket.codebuild.id
  acl    = "private"
}


resource "aws_codepipeline" "codepipeline" {
  name     = "wsi-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    type = "S3"
    location = var.ap_codepipeline_bucket
    region = "ap-northeast-2"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName = aws_codecommit_repository.code.repository_name
        BranchName = "main"
        PollForSourceChanges = "false"
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.build.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy-us-east-1"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ApplicationName = aws_codedeploy_app.app.name
        DeploymentGroupName = aws_codedeploy_deployment_group.dg.deployment_group_name
      }
    }

    action {
      name            = "Deploy-ap-northeast-2"
      category        = "Deploy"
      owner           = "AWS"
      region = "ap-northeast-2"
      provider        = "CodeDeploy"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ApplicationName = aws_codedeploy_app.app.name
        DeploymentGroupName = aws_codedeploy_deployment_group.dg.deployment_group_name
      }
    }
  }
}

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket_prefix = "skills-artifacts"
  force_destroy = true
}


data "aws_iam_policy_document" "assume_role_pipeline" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name               = "us-skills-role-codepipeline"
  assume_role_policy = data.aws_iam_policy_document.assume_role_pipeline.json
}

data "aws_iam_policy_document" "codepipeline_policy" {
  statement {
    effect = "Allow"

    actions = [
      "kms:*",
      "codecommit:*",
      "codebuild:*",
      "logs:*",
      "codedeploy:*",
      "s3:*",
      "ecs:*"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "us-codepipeline_policy"
  role   = aws_iam_role.codepipeline_role.id
  policy = data.aws_iam_policy_document.codepipeline_policy.json
}

resource "aws_cloudwatch_event_rule" "event" {
  name = "skills-ci-event"

  event_pattern = <<EOF
{
  "source": [ "aws.codecommit" ],
  "detail-type": [ "CodeCommit Repository State Change" ],
  "resources": [ "${aws_codecommit_repository.code.arn}" ],
  "detail": {
     "event": [
       "referenceCreated",
       "referenceUpdated"
      ],
     "referenceType":["branch"],
     "referenceName": ["main"]
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "event" {
  target_id = "skills-ci-event-target"
  rule = aws_cloudwatch_event_rule.event.name
  arn = aws_codepipeline.codepipeline.arn
  role_arn = aws_iam_role.ci.arn
}

resource "aws_iam_role" "ci" {
  name = "us-skills-ci"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "ci" {
  statement {
    actions = [
      "iam:PassRole",
      "codepipeline:*"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "ci" {
  name = "skills-ci-policy"
  policy = data.aws_iam_policy_document.ci.json
}

resource "aws_iam_role_policy_attachment" "ci" {
  policy_arn = aws_iam_policy.ci.arn
  role = aws_iam_role.ci.name
}
