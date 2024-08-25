resource "aws_ecr_repository" "ecr" {
  name = "eks-logging-ecr"
  force_delete = true
}