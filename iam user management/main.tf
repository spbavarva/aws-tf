resource "aws_iam_user" "users" {
  for_each = {
    for user in local.users : "${user.first_name} ${user.last_name}" => user
  }
  name = lower("${each.value.first_name}-${each.value.last_name}")
  path = "/users/"

  tags = {
    "DisplayName" = "${each.value.first_name} ${each.value.last_name}"
    "Role"        = each.value.role
    "Department"  = each.value.department
  }
}

resource "aws_iam_user_login_profile" "users" {
  for_each                = aws_iam_user.users
  user                    = each.value.name
  password_reset_required = true

  lifecycle {
    ignore_changes = [password_reset_required, password_length]
  }
}


resource "aws_iam_group_policy_attachment" "engineering_readonly" {
  group      = aws_iam_group.departments["Engineering"].name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_policy" "require_mfa" {
  name   = "RequireMFA"
  policy = file("${path.module}/require-mfs.json")
}

resource "aws_iam_group_policy_attachment" "require_mfa" {
  for_each = aws_iam_group.departments

  group      = each.value.name
  policy_arn = aws_iam_policy.require_mfa.arn
}
