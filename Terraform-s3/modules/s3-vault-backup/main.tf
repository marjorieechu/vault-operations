
resource "aws_s3_bucket" "vault_backup" {
  provider      = aws.state
  force_destroy = var.config.force_destroy
  bucket        = format("%s-%s-vault-backup", var.tags["environment"], var.tags["project"])
  tags          = var.tags
}

resource "aws_s3_bucket_replication_configuration" "vault_backup" {
  depends_on = [
    aws_s3_bucket.vault_backup,
    aws_s3_bucket.replication_bucket
  ]
  bucket = aws_s3_bucket.vault_backup.id
  role   = aws_iam_role.s3_replication_role.arn

  rule {
    id     = "StateReplicationAll"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.replication_bucket.arn
      storage_class = "STANDARD"
    }
  }
}

resource "aws_s3_bucket" "replication_bucket" {
  provider      = aws.backup
  force_destroy = var.config.force_destroy
  bucket        = format("%s-%s-vault-replication-bucket", var.tags["environment"], var.tags["project"])
  tags          = var.tags
}

resource "aws_s3_bucket_versioning" "vault_backup" {
  provider   = aws.state
  bucket     = aws_s3_bucket.vault_backup.id
  depends_on = [aws_s3_bucket.vault_backup]
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "replication_bucket" {
  provider   = aws.backup
  bucket     = aws_s3_bucket.replication_bucket.id
  depends_on = [aws_s3_bucket.replication_bucket]
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "vault_backup_encryption" {
  bucket = aws_s3_bucket.vault_backup.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"  # or "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "vault_backup_block" {
  bucket = aws_s3_bucket.vault_backup.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}




