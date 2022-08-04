resource "aws_s3_bucket" "this" {
  for_each = {for sm in var.buckets:  sm.bucket => sm}

  bucket = each.key
  acl = each.value.acl
  tags = each.value.tags
  force_destroy = each.value.force_destroy
  acceleration_status = each.value.acceleration_status
  request_payer = each.value.request_payer

  dynamic "website" {
    for_each = each.value.website != null ? (length(keys(each.value.website)) == 0 ? [] : [each.value.website]) : []

    content {
      index_document           = lookup(website.value, "index_document", null)
      error_document           = lookup(website.value, "error_document", null)
      redirect_all_requests_to = lookup(website.value, "redirect_all_requests_to", null)
      routing_rules            = lookup(website.value, "routing_rules", null)
    }
  }

  dynamic "cors_rule" {
    for_each = each.value.cors_rule != null ? each.value.cors_rule : []

    content {
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      allowed_headers = lookup(cors_rule.value, "allowed_headers", null)
      expose_headers  = lookup(cors_rule.value, "expose_headers", null)
      max_age_seconds = lookup(cors_rule.value, "max_age_seconds", null)
    }
  }

  dynamic "versioning" {
    for_each = each.value.versioning != null ? (length(keys(each.value.versioning)) == 0 ? [] : [each.value.versioning]) : []

    content {
      enabled    = lookup(versioning.value, "enabled", null)
      mfa_delete = lookup(versioning.value, "mfa_delete", null)
    }
  }

  dynamic "logging" {
    for_each = each.value.logging != null ? (length(keys(each.value.logging)) == 0 ? [] : [each.value.logging]) : []

    content {
      target_bucket = logging.value.target_bucket
      target_prefix = lookup(logging.value, "target_prefix", null)
    }
  }

  dynamic "lifecycle_rule" {
    for_each = each.value.lifecycle_rule != null ? (each.value.lifecycle_rule != null ? each.value.lifecycle_rule : []) : []

    content {
      id                                     = lookup(lifecycle_rule.value, "id", null)
      prefix                                 = lookup(lifecycle_rule.value, "prefix", null)
      tags                                   = lookup(lifecycle_rule.value, "tags", null)
      abort_incomplete_multipart_upload_days = lookup(lifecycle_rule.value, "abort_incomplete_multipart_upload_days", null)
      enabled                                = lifecycle_rule.value.enabled

      # Max 1 block - expiration
      dynamic "expiration" {
        for_each = length(keys(lookup(lifecycle_rule.value, "expiration", {}))) == 0 ? [] : [lookup(lifecycle_rule.value, "expiration", {})]

        content {
          date                         = lookup(expiration.value, "date", null)
          days                         = lookup(expiration.value, "days", null)
          expired_object_delete_marker = lookup(expiration.value, "expired_object_delete_marker", null)
        }
      }

      # Several blocks - transition
      dynamic "transition" {
        for_each = lookup(lifecycle_rule.value, "transition", [])

        content {
          date          = lookup(transition.value, "date", null)
          days          = lookup(transition.value, "days", null)
          storage_class = transition.value.storage_class
        }
      }

      # Max 1 block - noncurrent_version_expiration
      dynamic "noncurrent_version_expiration" {
        for_each = length(keys(lookup(lifecycle_rule.value, "noncurrent_version_expiration", {}))) == 0 ? [] : [lookup(lifecycle_rule.value, "noncurrent_version_expiration", {})]

        content {
          days = lookup(noncurrent_version_expiration.value, "days", null)
        }
      }

      # Several blocks - noncurrent_version_transition
      dynamic "noncurrent_version_transition" {
        for_each = lookup(lifecycle_rule.value, "noncurrent_version_transition", [])

        content {
          days          = lookup(noncurrent_version_transition.value, "days", null)
          storage_class = noncurrent_version_transition.value.storage_class
        }
      }
    }
  }

  # Max 1 block - replication_configuration
  dynamic "replication_configuration" {
    for_each = each.value.replication_configuration != null ? (length(keys(each.value.replication_configuration)) == 0 ? [] : [each.value.replication_configuration]) : []

    content {
      role = replication_configuration.value.role

      dynamic "rules" {
        for_each = replication_configuration.value.rules

        content {
          id       = lookup(rules.value, "id", null)
          priority = lookup(rules.value, "priority", null)
          prefix   = lookup(rules.value, "prefix", null)
          status   = rules.value.status

          dynamic "destination" {
            for_each = length(keys(lookup(rules.value, "destination", {}))) == 0 ? [] : [lookup(rules.value, "destination", {})]

            content {
              bucket             = destination.value.bucket
              storage_class      = lookup(destination.value, "storage_class", null)
              replica_kms_key_id = lookup(destination.value, "replica_kms_key_id", null)
              account_id         = lookup(destination.value, "account_id", null)

              dynamic "access_control_translation" {
                for_each = length(keys(lookup(destination.value, "access_control_translation", {}))) == 0 ? [] : [lookup(destination.value, "access_control_translation", {})]

                content {
                  owner = access_control_translation.value.owner
                }
              }
            }
          }

          dynamic "source_selection_criteria" {
            for_each = length(keys(lookup(rules.value, "source_selection_criteria", {}))) == 0 ? [] : [lookup(rules.value, "source_selection_criteria", {})]

            content {

              dynamic "sse_kms_encrypted_objects" {
                for_each = length(keys(lookup(source_selection_criteria.value, "sse_kms_encrypted_objects", {}))) == 0 ? [] : [lookup(source_selection_criteria.value, "sse_kms_encrypted_objects", {})]

                content {

                  enabled = sse_kms_encrypted_objects.value.enabled
                }
              }
            }
          }

          dynamic "filter" {
            for_each = length(keys(lookup(rules.value, "filter", {}))) == 0 ? [] : [lookup(rules.value, "filter", {})]

            content {
              prefix = lookup(filter.value, "prefix", null)
              tags   = lookup(filter.value, "tags", null)
            }
          }

        }
      }
    }
  }

  # Max 1 block - server_side_encryption_configuration
  dynamic "server_side_encryption_configuration" {
    for_each = each.value.server_side_encryption_configuration != null ? (length(keys(each.value.server_side_encryption_configuration)) == 0 ? [] : [each.value.server_side_encryption_configuration]) : []

    content {

      dynamic "rule" {
        for_each = length(keys(lookup(server_side_encryption_configuration.value, "rule", {}))) == 0 ? [] : [lookup(server_side_encryption_configuration.value, "rule", {})]

        content {

          dynamic "apply_server_side_encryption_by_default" {
            for_each = length(keys(lookup(rule.value, "apply_server_side_encryption_by_default", {}))) == 0 ? [] : [
            lookup(rule.value, "apply_server_side_encryption_by_default", {})]

            content {
              sse_algorithm     = apply_server_side_encryption_by_default.value.sse_algorithm
              kms_master_key_id = lookup(apply_server_side_encryption_by_default.value, "kms_master_key_id", null)
            }
          }
        }
      }
    }
  }

  # Max 1 block - object_lock_configuration
  dynamic "object_lock_configuration" {
    for_each = each.value.object_lock_configuration != null ? (length(keys(each.value.object_lock_configuration)) == 0 ? [] : [each.value.object_lock_configuration]) :[]

    content {
      object_lock_enabled = object_lock_configuration.value.object_lock_enabled

      dynamic "rule" {
        for_each = length(keys(lookup(object_lock_configuration.value, "rule", {}))) == 0 ? [] : [lookup(object_lock_configuration.value, "rule", {})]

        content {
          default_retention {
            mode  = lookup(lookup(rule.value, "default_retention", {}), "mode")
            days  = lookup(lookup(rule.value, "default_retention", {}), "days", null)
            years = lookup(lookup(rule.value, "default_retention", {}), "years", null)
          }
        }
      }
    }
  }

}

resource "aws_s3_bucket_policy" "this" {

  for_each = {
    # for k, r in var.buckets : k => r 
    # if (values("attach_policy") == true) 
    for k, r in var.buckets: k => r if contains(keys(r), "attach_policy") && r.attach_policy == true 
  }

  bucket = aws_s3_bucket.this[each.value.bucket].id
  policy = each.value.attach_elb_log_delivery_policy != null ? (each.value.attach_elb_log_delivery_policy ? data.aws_iam_policy_document.elb_log_delivery[0].json : each.value.policy) : each.value.policy
}

# AWS Load Balancer access log delivery policy
data "aws_elb_service_account" "this" {
  for_each = {
    # for k, r in var.buckets : k => r
    # if contains(keys(r), "attach_elb_log_delivery_policy")
        for k, r in var.buckets: k => r if contains(keys(r), "attach_elb_log_delivery_policy") && r.attach_elb_log_delivery_policy == true 

  }
}

data "aws_iam_policy_document" "elb_log_delivery" {
  for_each = {
    # for k, r in var.buckets : k => r
    # if contains(keys(r), "attach_elb_log_delivery_policy")
    for k, r in var.buckets: k => r if contains(keys(r), "attach_elb_log_delivery_policy") && r.attach_elb_log_delivery_policy == true 

  }

  statement {
    sid = ""

    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.this[0].arn]
    }

    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.this[each.value.bucket].id}/*",
    ]
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
   for_each = {
    # for k, r in var.buckets : k => r
    # if contains(keys(r), "attach_public_policy")
    for k, r in var.buckets: k => r if contains(keys(r), "attach_public_policy") && r.attach_public_policy == true 

  }

  // Chain resources (s3_bucket -> s3_bucket_policy -> s3_bucket_public_access_block)
  // to prevent "A conflicting conditional operation is currently in progress against this resource."
  bucket = aws_s3_bucket.this[each.value.bucket].id 

  block_public_acls       = each.value.block_public_acls
  block_public_policy     = each.value.block_public_policy
  ignore_public_acls      = each.value.ignore_public_acls
  restrict_public_buckets = each.value.restrict_public_buckets
}
