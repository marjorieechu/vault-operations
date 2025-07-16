locals {
  env = merge(
    yamldecode(file("${path.module}/../../environments/region.yaml")).alias,
    yamldecode(file("${path.module}/../../environments/webforx.yaml"))
  )
}

terraform {
  required_version = ">= 1.10.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "development-webforx-stage-tf-state"
    key            = "webforx/s3-vault-backup/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "development-webforx-stage-tf-state-lock"
  }
}

module "s3-vault-backup" {
  source             = "../../modules/s3-vault-backup"
  config             = local.env.s3
  tags               = local.env.tags
  source_bucket      = local.env.s3-vault.source_bucket
  destination_bucket = local.env.s3-vault.destination_bucket
}
