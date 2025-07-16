# IAM Role for S3 Replication
resource "aws_iam_role" "s3_replication_role" {
  provider = aws.state
  name     = format("%s-%s-vault-s3-replication-role", var.tags["environment"], var.tags["project"])


  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "s3.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# IAM Policy for the replication role
resource "aws_iam_policy" "s3_replication_policy" {
  name = "s3-replication-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowReplicationSourceAccess"
        Effect = "Allow"
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket",
          "s3:GetObjectVersion",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionTagging"
        ]
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.vault_backup.arn}",
          "arn:aws:s3:::${aws_s3_bucket.vault_backup.arn}/*"
        ]
      },
      {
        Sid    = "AllowReplicationDestinationAccess"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags",
          "s3:ObjectOwnerOverrideToBucketOwner"
        ]
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.replication_bucket.arn}",
          "arn:aws:s3:::${aws_s3_bucket.replication_bucket.arn}/*"
        ]
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "replication_attachment" {
  provider   = aws.state
  role       = aws_iam_role.s3_replication_role.name
  policy_arn = aws_iam_policy.s3_replication_policy.arn
}