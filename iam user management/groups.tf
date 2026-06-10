resource "aws_iam_group" "departments" {
  for_each = local.departments

  name = each.value
  path = "/groups/"
}

resource "aws_iam_group_membership" "departments" {
  for_each = local.departments

  name  = "${lower(each.value)}-membership"
  group = aws_iam_group.departments[each.value].name

  users = [
    for user in local.users :
    lower("${user.first_name}-${user.last_name}")
    if user.department == each.value
  ]
}
