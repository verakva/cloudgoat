#Secret S3 Bucket
resource "aws_s3_bucket" "cg-cardholder-data-bucket" {
  bucket        = "cg-cardholder-data-bucket-${local.s3_bucket_suffix}"
  force_destroy = true

  tags = merge(local.default_tags, {
    Name        = "cg-cardholder-data-bucket-${local.s3_bucket_suffix}"
    Description = "CloudGoat ${var.cgid} S3 Bucket used for storing sensitive cardholder data."
  })
}

# S3 Objects Uploaded
resource "aws_s3_object" "s3-objects" {
  for_each = toset(local.s3_objects)

  bucket = aws_s3_bucket.cg-cardholder-data-bucket.id
  key    = each.key
  source = "../assets/${each.key}"

  tags = merge(local.default_tags, {
    Name = "cardholder-data-${var.cgid}"
  })
}

# Block Public Access to Bucket
resource "aws_s3_bucket_public_access_block" "cg-cardholder-data-block-access" {
  bucket = aws_s3_bucket.cg-cardholder-data-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
