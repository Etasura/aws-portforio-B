locals {
  project = var.project

  tags = {
    Project = var.project
    Owner   = "Etasura" # 任意：GitHub名や名前など
  }

  lambda_name = "${var.project}-contact"
  bucket_name = "${var.project}-static-site"
  api_name    = "${var.project}-api"
}
