resource "aws_sns_topic" "topic" {
  name_prefix = var.name_prefix
}

resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = aws_sns_topic.topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.function.arn
}
