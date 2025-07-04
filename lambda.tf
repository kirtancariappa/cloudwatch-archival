resource "aws_lambda_function" "cw_log_archiver" {
  function_name = "cw-log-archiver"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.10"
  timeout       = 60
  memory_size   = 256

  filename         = "lambda_payload.zip"
  source_code_hash = filebase64sha256("lambda_payload.zip")
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/cw-log-archiver"
  retention_in_days = 7
}
