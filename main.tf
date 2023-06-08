terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.1.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

###################
# iam
###################
resource "aws_iam_user" "admin" {
  name          = "Administrator"
  force_destroy = true
  tags = {
    environment = "development"
  }
}

resource "aws_iam_user_login_profile" "admin" {
  user                    = aws_iam_user.admin.name
  password_reset_required = true
}

resource "aws_iam_user_policy_attachment" "admin" {
  user       = aws_iam_user.admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "local_file" "user_info" {
  depends_on = [aws_iam_user.admin, aws_iam_user_login_profile.admin]
  filename   = "${pathexpand("../")}/user_info.txt"
  content    = "IAM User Name: ${aws_iam_user.admin.name}\nPassword: ${aws_iam_user_login_profile.admin.password}"
}

###################
# cloudwatch
###################

resource "aws_sns_topic" "billing" {
  name = "Billing"
}

resource "aws_sns_topic_subscription" "user_subscription" {
  topic_arn = aws_sns_topic.billing.arn
  protocol  = "email"
  endpoint  = "test@gmail.com"
}

resource "aws_cloudwatch_metric_alarm" "alarm" {
  alarm_name          = "Billing-Alarm"
  alarm_description   = "テストアラーム詳細"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = "21600"
  statistic           = "Maximum"
  threshold           = "10"
  alarm_actions       = [aws_sns_topic.billing.arn]
}
