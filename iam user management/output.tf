output "account_id" {
  value = data.aws_caller_identity.name
}

output "user_count" {
  value = length(local.users)
}

output "usernames" {
  value = [for user in local.users : "${user.first_name} ${user.last_name}"]
}

output "user_passwords" {
  value = {
    for user, profile in aws_iam_user_login_profile.users :
    user => "password created for ${user} is ${profile.password}"
  }
  sensitive = true
}
