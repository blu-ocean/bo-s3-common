provider "aws" {
  region  = "us-east-1"
  version = "~> 2.68"
}

locals {
  bucket_name = "s3-bucket-${random_pet.this.id}"
}

resource "random_pet" "this" {
  length = 2
}

# resource "aws_kms_key" "objects" {
#   description             = "KMS key is used to encrypt bucket objects"
#   deletion_window_in_days = 7
# }

resource "aws_iam_role" "this" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "bucket_policy1" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.this.arn]
    }

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::bucket1-terraform-bulk-sample",
    ]
  }
}

data "aws_iam_policy_document" "bucket_policy2" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.this.arn]
    }

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::bucket2-terraform-bulk-sample",
    ]
  }
}

module "s3_bulk" {
  source = "../"
  buckets = [
  {
    bucket = "bucket1-terraform-bulk-sample"
    acl = "private"
    force_destroy = true
    attach_policy = false
    policy = data.aws_iam_policy_document.bucket_policy1.json
    tags = {
      Owner = "Toyota"
    }
    versioning = {
      enabled = true
    }
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
    acceleration_status = null
    request_payer  = null
    website = null
    cors_rule = null
    logging = null
    object_lock_configuration = null
    server_side_encryption_configuration = null
    replication_configuration = null
    lifecycle_rule = null
    attach_elb_log_delivery_policy = null
    attach_public_policy = null
  },
  { 
    bucket = "bucket2-terraform-bulk-sample"
    acl = "private"
    force_destroy = true
    attach_policy = true
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
    policy = data.aws_iam_policy_document.bucket_policy2.json
    tags = {
      Owner = "Toyota"
    }
    versioning = {
      enabled = true
    }
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
    acceleration_status = null
    request_payer  = null
    website = {
      index_document = "index.html"
      error_document = "error.html"
      routing_rules = jsonencode([{
        Condition : {
          KeyPrefixEquals : "docs/"
        },
        Redirect : {
          ReplaceKeyPrefixWith : "documents/"
        }
      }])
    }
    cors_rule = [
      {
        allowed_methods = ["PUT", "POST"]
        allowed_origins = ["https://modules.tf", "https://terraform-aws-modules.modules.tf"]
        allowed_headers = ["*"]
        expose_headers  = ["ETag"]
        max_age_seconds = 3000
        }, {
        allowed_methods = ["PUT"]
        allowed_origins = ["https://example.com"]
        allowed_headers = ["*"]
        expose_headers  = ["ETag"]
        max_age_seconds = 3000
      }
    ]
    logging = null
    object_lock_configuration = null
    server_side_encryption_configuration = null
    replication_configuration = null
    lifecycle_rule = null 
    attach_elb_log_delivery_policy = null
    attach_public_policy = null
  }
]
}

