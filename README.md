# AWS Portfolio B - Contact Form with S3 + API Gateway + Lambda (Python) + Terraform

## 概要
このプロジェクトは、静的ウェブサイト上のお問い合わせフォームを AWS サービスを組み合わせて構築した例です。  
S3 を利用した静的ホスティング、API Gateway を利用したエンドポイント公開、Lambda (Python) を用いたサーバーレス処理を Terraform で IaC 化しています。

## アーキテクチャ
- **Amazon S3**: 静的サイトホスティング（HTML/CSS/JavaScript）
- **Amazon API Gateway**: HTTP API エンドポイント（CORS対応）
- **AWS Lambda**: Python によるフォーム送信処理
- **Amazon CloudWatch Logs**: API Gateway・Lambda のログ出力
- **Terraform**: インフラ構成管理・デプロイ

### 構成図
![Architecture](diagrams/portfolio-b.png)

## ディレクトリ構成
```
portfolio-b/
├── apigw.tf             # API Gateway 関連リソース定義
├── lambda.tf            # Lambda 関数と関連IAMロール定義
├── s3.tf                # S3バケット、静的ホスティング設定
├── iam.tf               # IAMロール・ポリシー
├── locals.tf            # ローカル変数定義
├── variables.tf         # 変数定義
├── versions.tf          # Terraformバージョン・プロバイダー設定
└── main.py              # Lambda 関数の Python コード
```

## 主な機能
1. **静的サイトホスティング**  
   - S3バケットに index.html を配置
   - CORS 対応のバケットポリシー適用

2. **API Gateway + Lambda 連携**  
   - POST メソッドでフォームデータを Lambda に送信
   - OPTIONS メソッドによる CORS プリフライト応答

3. **監視・ログ**  
   - API Gateway ステージのアクセスログ設定
   - Lambda 実行ログを CloudWatch Logs に出力

4. **セキュリティ・ベストプラクティス**  
   - S3 バージョニング有効化
   - アクセスログ記録
   - 最小権限の IAM ロール付与

## セットアップ手順
### 前提条件
- Terraform v1.x
- AWS CLI 設定済み（プロファイル有効）
- Python 3.12

### デプロイ
```bash
terraform init
terraform plan
terraform apply
```

### 動作確認
1. `terraform output` で S3 バケット URL と API Gateway URL を確認
2. ブラウザで静的サイトにアクセス
3. フォーム送信で Lambda が実行されることを確認

### 削除
```bash
terraform destroy
```

## 改善予定
- CloudFront を経由した HTTPS 配信
- WAF 追加によるセキュリティ強化
- CI/CD（GitHub Actions）導入
