resource "aws_ecr_repository" "ecs-container" {
  name                 = "ecs-container"
  image_tag_mutability = "MUTABLE"
}