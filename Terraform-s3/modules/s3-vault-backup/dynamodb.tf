resource "aws_dynamodb_table" "vault-backup-lock" {
  provider       = aws.state
  name           = format("%s-%s-vault-backup-lock", var.tags["environment"], var.tags["project"])
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = var.tags
}