###################################################
#
#  S3 Bootstrap Configuration
#
###################################################

resource "aws_s3_bucket" "s3_bucket_palo" {
  bucket = "${lower(var.palo_name)}-${resource.random_uuid.s3postfix.result}"

#   bucket = "${lower(var.palo_name)}-${lower(var.s3_bucket_prefix_palo)}-${random_uuid.uuid.result}"
#   force_destroy = false
}

resource "aws_s3_bucket_object" "config" {
    bucket = aws_s3_bucket.s3_bucket_palo.id
    key    = "config/"
    content_type = "application/x-directory"
}

resource "aws_s3_bucket_object" "content" {
    bucket = aws_s3_bucket.s3_bucket_palo.id
    key    = "content/"
    content_type = "application/x-directory"
}

resource "aws_s3_bucket_object" "license" {
    bucket = aws_s3_bucket.s3_bucket_palo.id
    key    = "license/"
    content_type = "application/x-directory"
}

resource "aws_s3_bucket_object" "software" {
    bucket = aws_s3_bucket.s3_bucket_palo.id
    key    = "software/"
    content_type = "application/x-directory"
}

# Upload bootstrap
resource "aws_s3_bucket_object" "bootstrap" {
  bucket = aws_s3_bucket.s3_bucket_palo.id
  key    = "/config/bootstrap.xml"
  source = "./bootstrap.xml"
  etag = filemd5("./bootstrap.xml")
}

# Upload bootstrap
resource "aws_s3_bucket_object" "initcfg" {
  bucket = aws_s3_bucket.s3_bucket_palo.id
  key    = "/config/init-cfg.txt"
  source = "./init-cfg.txt"
  etag = filemd5("./init-cfg.txt")
}

