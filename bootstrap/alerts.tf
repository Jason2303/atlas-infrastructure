resource "aws_sns_topic" "budget_alerts" {
  name = "atlas-budget-alerts"
}


resource "aws_sns_topic_policy" "budget_alerts" {
  arn    = aws_sns_topic.budget_alerts.arn
  policy = data.aws_iam_policy_document.sns_budget_policy.json
}

data "aws_iam_policy_document" "sns_budget_policy" {
  policy_id = "BudgetPolicy001"

  statement {
    actions = ["SNS:Publish"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
      values = [data.aws_caller_identity.current.account_id]
    }

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["budgets.amazonaws.com"]
    }

    resources = [aws_sns_topic.budget_alerts.arn]
    sid = "AWSBudgetsSNSPublishingPermissions"
  }
}

resource "aws_sns_topic_subscription" "email_target" {
  topic_arn = aws_sns_topic.budget_alerts.arn
  protocol  = "email"
  endpoint  = var.email
}