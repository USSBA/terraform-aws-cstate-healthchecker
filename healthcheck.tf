resource "aws_route53_health_check" "healthchecks" {
  count             = length(var.healthchecks)
  fqdn              = var.healthchecks[count.index].fqdn
  port              = var.healthchecks[count.index].port
  type              = var.healthchecks[count.index].type
  resource_path     = var.healthchecks[count.index].resource_path
  failure_threshold = "5"
  request_interval  = "30"
  regions           = length(var.healthcheck_regions) == 0 ? null : var.healthcheck_regions
}

resource "aws_cloudwatch_metric_alarm" "foobar" {
  count               = length(var.healthchecks)
  alarm_name          = var.healthchecks[count.index].alarm_name
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.healthchecks[count.index].evaluation_periods
  metric_name         = "HealthCheckPercentageHealthy"
  namespace           = "AWS/Route53"
  period              = "60"
  statistic           = "Average"
  threshold           = "50"
  alarm_description   = "This monitors R53 for ${var.healthchecks[count.index].alarm_name}"
  alarm_actions       = aws_sns_topic.topic.arn
  ok_actions          = aws_sns_topic.topic.arn
  dimensions = {
    HealthCheckId = aws_route53_health_check.healthchecks[count.index].id
  }
  # TODO: default is missing, do we want to ignore and maintain last known state instead?
  # treat_missing_data  = "ignore"
}
