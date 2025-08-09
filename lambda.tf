data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/src/lambda/main.py"
  output_path = "${path.module}/src/lambda/main.zip"
}

resource "aws_lambda_function" "contact" {
  function_name = local.lambda_name
  filename      = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  handler = "main.handler"
  runtime = "python3.12"
  role    = aws_iam_role.lambda_exec_role.arn
  timeout = 10

  tags = local.tags
}
