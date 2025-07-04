resource "aws_cloudwatch_event_rule" "every_25_min" {
  name                = "log-archive-every-25min"
  schedule_expression = "rate(25 minutes)"
}

resource "aws_cloudwatch_event_target" "lambda_trigger" {
  rule      = aws_cloudwatch_event_rule.every_25_min.name
  target_id = "cw-log-archiver"
  arn       = aws_lambda_function.cw_log_archiver.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "allow-cloudwatch-events-25min"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cw_log_archiver.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_25_min.arn
}
