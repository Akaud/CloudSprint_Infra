output "github_actions_user_arn" {
  description = "ARN of the GitHub Actions IAM user"
  value       = aws_iam_user.github_actions.arn
}

output "github_actions_user_name" {
  description = "Name of the GitHub Actions IAM user"
  value       = aws_iam_user.github_actions.name
}

output "github_actions_access_key_id" {
  description = "Access Key ID for GitHub Actions"
  value       = aws_iam_access_key.github_actions.id
  sensitive   = true
}

output "github_actions_secret_access_key" {
  description = "Secret Access Key for GitHub Actions"
  value       = aws_iam_access_key.github_actions.secret
  sensitive   = true
}
