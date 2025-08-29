# Simple IAM User for GitHub Actions (for testing)
resource "aws_iam_user" "github_actions" {
  name = "github-actions-user-${var.environment}"
  path = "/"
}

# Create access keys for the user
resource "aws_iam_access_key" "github_actions" {
  user = aws_iam_user.github_actions.name
}

# Attach S3 and CloudFront policies
resource "aws_iam_user_policy_attachment" "s3_full_access" {
  user       = aws_iam_user.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_user_policy_attachment" "cloudfront_full_access" {
  user       = aws_iam_user.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/CloudFrontFullAccess"
}
