variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "ap-northeast-1"
}

variable "aws_profile" {
  description = "~/.aws/credentials に記載されているプロファイル名"
  default     = "default"
}

variable "project" {
  description = "プロジェクト名（プレフィックスに使用）"
  default     = "portfolio-b"
}
