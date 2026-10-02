resource "aws_ecr_repository" "plane_ecr" {
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE"
  force_delete         = false

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name = var.repository_name
  }
}