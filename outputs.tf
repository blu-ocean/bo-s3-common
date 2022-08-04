output "bucket_ids" {
  description = "The name of the bucket."
  # value       = element(concat(aws_s3_bucket_policy.this.*.id, aws_s3_bucket.this.*.id, list("")), 0)
  value = [for k, v in aws_s3_bucket.this : zipmap(
    ["${k}-id"],
    [v.id ]
  )]
}

output "bucket_arns" {
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname."
  # value       = element(concat(aws_s3_bucket.this.*.arn, list("")), 0)
  value = [for k, v in aws_s3_bucket.this : zipmap(
    ["${k}-arn"],
    [v.arn ]
  )]
}

output "bucket_website_endpoints" {
  description = "The website endpoint, if the bucket is configured with a website. If not, this will be an empty string."
  # value       = element(concat(aws_s3_bucket.this.*.website_endpoint, list("")), 0)
  value = [for k, v in aws_s3_bucket.this : zipmap(
    ["${k}-website_endpoint"],
    [v.website_endpoint ]
  )]
}

output "bucket_website_endpoint_domains" {
  description = "The domain of the website endpoint, if the bucket is configured with a website. If not, this will be an empty string. This is used to create Route 53 alias records. "
  # value       = element(concat(aws_s3_bucket.this.*.website_domain, list("")), 0)
  value = [for k, v in aws_s3_bucket.this : zipmap(
    ["${k}-website_domain"],
    [v.website_domain ]
  )]
}
