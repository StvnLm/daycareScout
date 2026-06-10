locals {
<<<<<<< Updated upstream
  github_owner = "stvnlm"
  github_repo  = "terraform-daycarewatch"
=======
  github_owner  = "StvnLm"
  github_repo   = "daycareScout"
>>>>>>> Stashed changes
  github_branch = "main"

  role_name  = "github-actions-${local.github_repo}"

  github_subject = "repo:${local.github_owner}/${local.github_repo}:ref:refs/heads/${local.github_branch}"
}

#########################################################
# To do: create new S3 bucket (daycareScout) and update #
# the backend state bucket to use new naming            # 
#########################################################

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
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
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [local.github_subject]
    }
  }
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
