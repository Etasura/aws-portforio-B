# AWS Portfolio B

## 概要
このプロジェクトは、AWS S3 + API Gateway + Lambda (Python) を用いたお問い合わせフォームのデモ構成です。
Terraform により IaC 化を行い、セキュリティベストプラクティスとして tfsec / checkov によるコードチェックを実施しています。

## 構成要素
- **S3**: 静的Webサイトホスティング
- **API Gateway**: Lambda へのHTTPインターフェース
- **Lambda (Python)**: お問い合わせ内容を処理
- **CloudWatch Logs**: API Gateway / Lambda のログ管理
- **Terraform**: インフラ構成管理

## デプロイ手順
1. `terraform init`
2. `terraform validate`
3. `terraform plan`
4. `terraform apply`

## セキュリティチェック
```bash
tfsec .
checkov -d .
```

## 構成図
`diagrams/portfolio-b.drawio` を参照してください。
