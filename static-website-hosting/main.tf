resource "aws_s3_bucket" "website_bucket" {
  bucket = var.website_bucket_name
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "bmw-m8-oac"
  description                       = "OAC for BMW M8 Website"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_s3_bucket_policy" "allow_access_from_cdn" {
  bucket     = aws_s3_bucket.website_bucket.id
  depends_on = [aws_s3_bucket_public_access_block.block_public_access]

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "Allow CDN",
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "cloudfront.amazonaws.com"
          },
          "Action" : [
            "s3:GetObject"
          ],
          "Resource" : "${aws_s3_bucket.website_bucket.arn}/*",
          "Condition" : {
            "StringEquals" : {
              "aws:SourceArn" : aws_cloudfront_distribution.s3_distribution.arn
            }
          }
        }
      ]
    }
  )
}


resource "aws_s3_object" "object" {
  for_each = fileset("${path.module}/www", "**/*")
  bucket   = aws_s3_bucket.website_bucket.id
  key      = each.value
  source   = "${path.module}/www/${each.value}"
  etag     = filemd5("${path.module}/www/${each.value}")

  content_type = lookup(
    {
      "html" = "text/html",
      "htm"  = "text/html",
      "css"  = "text/css",
      "js"   = "application/javascript",
      "png"  = "image/png",
      "jpg"  = "image/jpeg",
      "jpeg" = "image/jpeg",
      "gif"  = "image/gif",
      "ico"  = "image/x-icon",
      "json" = "application/json",
      "xml"  = "application/xml",
      "txt"  = "text/plain"
    },
    split(".", each.value)[length(split(".", each.value)) - 1],
    "application/octet-stream"
  )
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    origin_id                = local.origin_id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "BMW M8 Website Distribution"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment = "production"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }
}

action "aws_cloudfront_create_invalidation" "s3_invalidation" {
  config {
    distribution_id = aws_cloudfront_distribution.s3_distribution.id
    paths           = ["/*"]
  }
}

resource "terraform_data" "website_trigger" {
  input = sha256(join("", [
    for f in fileset("${path.module}/www", "**/*") :
    filemd5("${path.module}/www/${f}")
  ]))

  lifecycle {
    action_trigger {
      events  = [before_create, before_update]
      actions = [action.aws_cloudfront_create_invalidation.s3_invalidation]
    }
  }
}
