locals {
  github_oidc_url          = "https://token.actions.githubusercontent.com"
  github_oidc_host         = "token.actions.githubusercontent.com"
  github_oidc_provider_arn = var.create_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : var.existing_oidc_provider_arn
}

data "tls_certificate" "github" {
  url = local.github_oidc_url
}

resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_oidc_provider ? 1 : 0

  url = local.github_oidc_url

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    data.tls_certificate.github.certificates[0].sha1_fingerprint
  ]

  tags = var.tags
}

data "aws_iam_policy_document" "github_ecr_publisher_trust" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"
      identifiers = [
        local.github_oidc_provider_arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.github_oidc_host}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.github_oidc_host}:repository"
      values   = [var.github_repository]
    }

    condition {
      test     = "StringLike"
      variable = "${local.github_oidc_host}:sub"
      values   = var.allowed_subjects
    }
  }
}

resource "aws_iam_role" "github_ecr_publisher" {
  name               = "${var.name_prefix}-github-ecr-publisher"
  assume_role_policy = data.aws_iam_policy_document.github_ecr_publisher_trust.json

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-github-ecr-publisher"
  })
}

data "aws_iam_policy_document" "github_ecr_publisher" {
  statement {
    sid    = "GetEcrAuthorizationToken"
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "PushImagesToRentACarRepository"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]

    resources = [
      var.ecr_repository_arn
    ]
  }
}

resource "aws_iam_policy" "github_ecr_publisher" {
  name        = "${var.name_prefix}-github-ecr-publisher"
  description = "Least-privilege ECR publish policy for RentACar GitHub Actions."
  policy      = data.aws_iam_policy_document.github_ecr_publisher.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "github_ecr_publisher" {
  role       = aws_iam_role.github_ecr_publisher.name
  policy_arn = aws_iam_policy.github_ecr_publisher.arn
}
