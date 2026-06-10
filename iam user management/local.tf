locals {
  users = csvdecode(file("${path.module}/users.csv"))
}

locals {
  departments = toset([
    for user in local.users : user.department
  ])
}
