data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "plane_storage" {
  bucket        = "${var.project_name}-${data.aws_caller_identity.current.account_id}-storage"
  force_destroy = true

  tags = {
    Name = "${var.project_name}-storage"
  }
}

resource "aws_s3_bucket_public_access_block" "plane_storage" {
  bucket = aws_s3_bucket.plane_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "plane_storage" {
  bucket = aws_s3_bucket.plane_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "plane_storage" {
  bucket = aws_s3_bucket.plane_storage.id

  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_iam_role_policy" "plane_s3_access" {
  name = "${var.project_name}-s3-access"
  role = var.ecs_task_role_name

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:ListBucket"
        ]

        Resource = aws_s3_bucket.plane_storage.arn
      },
      {
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]

        Resource = "${aws_s3_bucket.plane_storage.arn}/*"
      }
    ]
  })
}