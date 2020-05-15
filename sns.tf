resource "aws_sns_topic" "issues" {
  name_prefix = var.name_prefix
}
