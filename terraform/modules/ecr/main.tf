data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "ecr_kms" {
  #checkov:skip=CKV_AWS_109:KMS key administration requires account-root delegation so IAM policies in the account can manage the key.
  #checkov:skip=CKV_AWS_111:KMS key administration is intentionally delegated to the owning AWS account root principal.
  #checkov:skip=CKV_AWS_356:KMS key policies use resource '*' because the policy is attached directly to the key it governs.
  statement {
    sid    = "EnableAccountAdministration"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }
}

resource "aws_kms_key" "ecr" {
  description             = "ECR encryption key for ${var.repository_name}"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.ecr_kms.json

  tags = merge(var.tags, {
    Name = "${var.repository_name}-ecr-key"
  })
}

resource "aws_kms_alias" "ecr" {
  name          = "alias/${var.repository_name}-ecr"
  target_key_id = aws_kms_key.ecr.key_id
}

resource "aws_ecr_repository" "this" {
  name                 = var.repository_name
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.ecr.arn
  }

  tags = merge(var.tags, {
    Name = var.repository_name
  })
}

resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Remove untagged images after ${var.untagged_image_expire_days} days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = var.untagged_image_expire_days
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Retain the last ${var.release_image_retention_count} tagged images"
        selection = {
          tagStatus = "tagged"
          tagPrefixList = [
            "release-",
            "main-",
            "sha-"
          ]
          countType   = "imageCountMoreThan"
          countNumber = var.release_image_retention_count
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
