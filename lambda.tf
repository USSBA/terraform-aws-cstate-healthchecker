resource "aws_iam_role" "lambda_role" {
  assume_role_policy = data.aws_iam_policy_document.lambda_trust_policy.json
  name_prefix        = var.name_prefix
}
resource "aws_iam_role_policy_attachment" "lambda_basic_exec_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.id
}
data "aws_iam_policy_document" "lambda_role_policy" {
  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameter"]
    resources = [var.github_conf.oauth_token_ssm_paramter_arn]
  }
}
resource "aws_iam_role_policy" "lambda_role_policy" {
  name_prefix = var.name_prefix
  policy      = data.aws_iam_policy_document.lambda_role_policy.json
  role        = aws_iam_role.lambda_role.id
}
data "archive_file" "package" {
  type        = "zip"
  source_dir  = "${path.module}/code/"
  output_path = "${path.module}/temp/${var.name_prefix}.zip"
}
resource "aws_lambda_function" "function" {
  filename         = data.archive_file.package.output_path
  source_code_hash = data.archive_file.package.output_base64sha256
  function_name    = var.name_prefix
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.lambda_handler"
  runtime          = "python3.8"
  timeout          = 10
  environment {
    variables = {
      GITHUB_ORG                        = var.github_conf.organization_name
      GITHUB_REPO                       = var.github_conf.repository_name
      GITHUB_REPO_BRANCH                = var.github_conf.branch_name
      GITHUB_OAUTH_TOKEN_SSM_PARAM_NAME = var.github_conf.oauth_token_ssm_paramter_arn
    }
  }
}


