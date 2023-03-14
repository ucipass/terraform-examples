###################################################
#
#
#  S3 Bootstrap Configuration
#
#
###################################################

resource "aws_s3_bucket" "s3_bucket_palo" {
  bucket = "${lower(var.palo_name)}-${resource.random_uuid.s3postfix.result}"

#   bucket = "${lower(var.palo_name)}-${lower(var.s3_bucket_prefix_palo)}-${random_uuid.uuid.result}"
#   force_destroy = false
}

resource "aws_s3_bucket_object" "config" {
    bucket = aws_s3_bucket.s3_bucket_palo.id
    acl    = "private"
    key    = "config/"
    content_type = "application/x-directory"
}

resource "aws_s3_bucket_object" "content" {
    bucket = aws_s3_bucket.s3_bucket_palo.id
    acl    = "private"
    key    = "content/"
    content_type = "application/x-directory"
}

resource "aws_s3_bucket_object" "license" {
    bucket = aws_s3_bucket.s3_bucket_palo.id
    acl    = "private"
    key    = "license/"
    content_type = "application/x-directory"
}

resource "aws_s3_bucket_object" "software" {
    bucket = aws_s3_bucket.s3_bucket_palo.id
    acl    = "private"
    key    = "software/"
    content_type = "application/x-directory"
}

# Upload bootstrap
resource "aws_s3_bucket_object" "bootstrap" {
  bucket = aws_s3_bucket.s3_bucket_palo.id
  key    = "/config/bootstrap.xml"
  acl    = "private" 
  source = "./bootstrap.xml"
  etag = filemd5("./bootstrap.xml")
}

# Upload bootstrap
resource "aws_s3_bucket_object" "initcfg" {
  bucket = aws_s3_bucket.s3_bucket_palo.id
  key    = "/config/init-cfg.txt"
  acl    = "private" 
  source = "./init-cfg.txt"
  etag = filemd5("./init-cfg.txt")
}

resource "aws_s3_bucket_acl" "s3_bucket_palo" {
  bucket = aws_s3_bucket.s3_bucket_palo.id
  acl    = "private"
}

# resource "aws_s3_bucket_cors_configuration" "s3_bucket_palo" {
#   bucket = aws_s3_bucket.s3_bucket_palo.id

#   cors_rule {
#     allowed_headers = ["*"]
#     allowed_methods = ["GET","PUT","DELETE","HEAD", "POST"]
#     allowed_origins = ["*"]
#     expose_headers  = ["ETag"]
#     max_age_seconds = 3000
#   }  

# }

# resource "aws_s3_bucket_lifecycle_configuration" "s3_bucket_palo" {
#   bucket = aws_s3_bucket.s3_bucket_palo.id

#   rule {
#     id = "rule-1"
#     expiration {
#         days = 1
#     }
#     filter {}
#     status = "Enabled"
#   }
# }
