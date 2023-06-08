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
