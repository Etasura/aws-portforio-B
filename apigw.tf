# REST API 本体の作成
resource "aws_api_gateway_rest_api" "contact_api" {
  name = local.api_name
  tags = local.tags
}

# "/" ルートの取得
data "aws_api_gateway_resource" "root" {
  rest_api_id = aws_api_gateway_rest_api.contact_api.id
  path        = "/"
}

# POSTメソッドの作成
resource "aws_api_gateway_method" "post_contact" {
  rest_api_id   = aws_api_gateway_rest_api.contact_api.id
  resource_id   = data.aws_api_gateway_resource.root.id
  http_method   = "POST"
  authorization = "NONE"
}

# Lambda統合設定（POST）
resource "aws_api_gateway_integration" "lambda_post" {
  rest_api_id             = aws_api_gateway_rest_api.contact_api.id
  resource_id             = data.aws_api_gateway_resource.root.id
  http_method             = aws_api_gateway_method.post_contact.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.contact.invoke_arn
}

# OPTIONSメソッド（CORSプリフライト対応）
resource "aws_api_gateway_method" "options_contact" {
  rest_api_id   = aws_api_gateway_rest_api.contact_api.id
  resource_id   = data.aws_api_gateway_resource.root.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_mock" {
  rest_api_id = aws_api_gateway_rest_api.contact_api.id
  resource_id = data.aws_api_gateway_resource.root.id
  http_method = aws_api_gateway_method.options_contact.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_200" {
  rest_api_id = aws_api_gateway_rest_api.contact_api.id
  resource_id = data.aws_api_gateway_resource.root.id
  http_method = aws_api_gateway_method.options_contact.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options_integration" {
  rest_api_id = aws_api_gateway_rest_api.contact_api.id
  resource_id = data.aws_api_gateway_resource.root.id
  http_method = aws_api_gateway_method.options_contact.http_method
  status_code = aws_api_gateway_method_response.options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  response_templates = {
    "application/json" = ""
  }
}

# デプロイとステージ作成
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.contact_api.id

  triggers = {
    redeploy = sha1(jsonencode(aws_api_gateway_rest_api.contact_api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.contact_api.id
  stage_name    = "prod"
  tags          = local.tags

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw_logs.arn
    format = jsonencode({
      requestId       = "$context.requestId",
      ip              = "$context.identity.sourceIp",
      caller          = "$context.identity.caller",
      user            = "$context.identity.user",
      requestTime     = "$context.requestTime",
      httpMethod      = "$context.httpMethod",
      resourcePath    = "$context.resourcePath",
      status          = "$context.status",
      protocol        = "$context.protocol",
      responseLength  = "$context.responseLength"
    })
  }

  xray_tracing_enabled = false
}


# Lambda への実行許可をAPI Gatewayに与える
resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.contact.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.contact_api.execution_arn}/*/*"
}

resource "aws_cloudwatch_log_group" "api_gw_logs" {
  name              = "/aws/apigateway/${local.project}-prod"
  retention_in_days = 14
}


# ロールにログ出力用のポリシーを付与
resource "aws_iam_role_policy" "api_gw_log_policy" {
  name = "${local.project}-apigw-log-policy"
  role = aws_iam_role.api_gw_log_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

# アカウントにログ出力ロールを紐づけ
resource "aws_api_gateway_account" "account" {
  cloudwatch_role_arn = aws_iam_role.api_gw_log_role.arn
  depends_on = [aws_iam_role_policy.api_gw_log_policy]
}
