# ログ保存用バケット
resource "aws_s3_bucket" "log" {
  bucket        = "${local.bucket_name}-log"
  force_destroy = true
  tags          = local.tags
}

resource "aws_s3_bucket_logging" "static" {
  bucket = aws_s3_bucket.static.id

  target_bucket = aws_s3_bucket.log.id
  target_prefix = "logs/"
}


resource "aws_s3_bucket" "static" {
  bucket        = local.bucket_name
  force_destroy = true
  tags          = local.tags
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.static.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# 公開アクセス許可（バケットポリシー）
data "aws_iam_policy_document" "public_read_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.static.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    effect = "Allow"
  }
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.static.id
  policy = data.aws_iam_policy_document.public_read_policy.json

  depends_on = [aws_s3_bucket_public_access_block.static]
}


resource "aws_s3_bucket_public_access_block" "static" {
  bucket = aws_s3_bucket.static.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_versioning" "static" {
  bucket = aws_s3_bucket.static.id

  versioning_configuration {
    status = "Enabled"
  }
}
