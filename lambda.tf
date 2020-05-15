resource "aws_iam_role" "lambda_role" {
  assume_role_policy = data.aws_iam_policy_document.lambda_trust_policy.json
  name_prefix = var.name_prefix
}
resource "aws_iam_role_policy_attachment" "lambda_basic_exec_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role = aws_iam_role.lambda_role.id
}
resource "aws_iam_role_policy" "lambda_role_policy" {
  name_prefix = var.name_prefix
  policy = data.aws_iam_policy_document.lambda_role_policy.json
  role = aws_iam_role.lambda_role.id
}
data "aws_iam_policy_document" "lambda_role_policy" {
  statement {
    effect = "Allow"
    actions = ["ssm:GetParameter"]
    resources = [var.github_conf.oauth_token_ssm_paramter_arn]
  }
}

