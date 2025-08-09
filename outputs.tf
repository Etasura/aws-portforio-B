output "api_invoke_url" {
  description = "API Gateway のエンドポイントURL"
  value       = aws_api_gateway_stage.prod.invoke_url
}

output "static_website_url" {
  description = "S3 静的ホスティングURL"
  value       = aws_s3_bucket_website_configuration.website.website_endpoint
}
