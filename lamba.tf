## AWS Lambda Function ##
## AWS Lambda API Requires a ZIP Files with the execution code
data "archive_file" "rotation_key_python" {
  type        = "zip"
  source_file = "rotation_key.py"
  output_path = "rotation_key.zip"

}


resource "aws_lambda_function" "rotate_access_keys_lambda" {
  filename      = data.archive_file.rotation_key_python.output_path
  function_name = "RotateAccessKeysLambda"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "rotation_key.lambda_handler"
  source_code_hash = filebase64sha256(data.archive_file.rotation_key_python.output_path)
  runtime       = "python3.9"  # Replace with your desired runtime (e.g., Node.js, Python)
  timeout = 300

}



resource "aws_lambda_permission" "rotate_access_keys_lambda_permission" {
  statement_id  = "AllowExecutionFromCloudWatchEvents"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rotate_access_keys_lambda.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.rotate_access_keys_rule.arn
}

resource "aws_cloudwatch_event_rule" "rotate_access_keys_rule" {
  name = "rotate-access-keys-rule"
  schedule_expression = "rate(1 Day)"
  depends_on = [
    aws_lambda_function.rotate_access_keys_lambda
  ]
}

resource "aws_cloudwatch_event_target" "rotate_access_keys_target" {
  rule = aws_cloudwatch_event_rule.rotate_access_keys_rule.name
  arn  = aws_lambda_function.rotate_access_keys_lambda.arn
}