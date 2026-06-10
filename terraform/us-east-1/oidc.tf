locals {
  github_owner = "StvnLm"
  github_repo  = "daycareScout"
  role_name    = "github-actions-${local.github_repo}"

  github_subject_prefix = "repo:${local.github_owner}/${local.github_repo}"
}

#########################################################
# To do: create new S3 bucket (daycareScout) and update #
# the backend state bucket to use new naming            # 
#########################################################

resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

data "aws_iam_policy_document" "github_actions_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "${local.github_subject_prefix}:ref:refs/heads/*",
        "${local.github_subject_prefix}:pull_request",
        "${local.github_subject_prefix}:environment:*",
      ]
    }
  }
}

resource "aws_iam_role_policy" "github_actions_backend_access" {
  name = "terraform-backend-access"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = "arn:aws:s3:::terraform-daycarewatch"
        Condition = {
          StringLike = {
            "s3:prefix" = [
              "us-east-1/terraform.tfstate",
              "us-east-1/terraform.tfstate.tflock"
            ]
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::terraform-daycarewatch/us-east-1/terraform.tfstate"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "arn:aws:s3:::terraform-daycarewatch/us-east-1/terraform.tfstate.tflock"
      }
    ]
  })
}

resource "aws_iam_role" "github_actions" {
  name               = local.role_name
  assume_role_policy = data.aws_iam_policy_document.github_actions_trust.json
}

resource "aws_iam_role_policy_attachment" "github_actions_readonly" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
}
