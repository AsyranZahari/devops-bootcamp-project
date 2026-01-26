# EN: AWS provider settings and S3 backend for state storage
# JP: AWSプロバイダーの設定とS3バックエンドの状態保存
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # EN: Store infrastructure state in S3 bucket to prevent data loss
  # JP: インフラの状態をS3バケットに保存し、紛失を防ぐ
  backend "s3" {
    bucket = "devops-bootcamp-terraform-asyran" 
    key    = "terraform.tfstate"
    region = "ap-southeast-1" 
  }
}

provider "aws" {
  region = "ap-southeast-1" 
}