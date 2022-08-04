output "bucket_ids" {
  description = "The name of the bucket."
  value       = module.s3_bulk.bucket_ids
}

output "bucket_arns" {
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname."
  value       = module.s3_bulk.bucket_arns
}


output "bucket_website_endpoints" {
  description = "The website endpoint, if the bucket is configured with a website. If not, this will be an empty string."
  value       = module.s3_bulk.bucket_website_endpoints
}

output "bucket_website_endpoint_domains" {
  description = "The domain of the website endpoint, if the bucket is configured with a website. If not, this will be an empty string. This is used to create Route 53 alias records. "
  value       = module.s3_bulk.bucket_website_endpoint_domains
}
