terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region = "us-east-1"
}

data "aws_availability_zones" "all" {}

# Provision an S3 bucket

resource "aws_s3_bucket" "serverless_bucket2" {
  # bucket = "${var.business_name}_${var.product_name}_${var.page}_392837492"
  bucket = var.s3_bucket_name

  versioning {
    enabled = true
  }

  tags = {
    Business = var.business_name
    Product = var.product_name
    Page = var.page
  }
}

resource "aws_s3_bucket_policy" "public_access2" {
  bucket = aws_s3_bucket.serverless_bucket2.id

  policy = <<POLICY
{
  "Version": "2008-10-17",
  "Statement": [
        {
            "Sid": "AllowPublicRead",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": "s3:GetObject",
            "Resource": "${aws_s3_bucket.serverless_bucket2.arn}/*"
            }
          ]
}
POLICY
}

resource "aws_s3_bucket_object" "css_folder" {
  bucket = aws_s3_bucket.serverless_bucket2.id
  key    = "assets/css"
}

resource "aws_s3_bucket_object" "images_folder" {
  bucket = aws_s3_bucket.serverless_bucket2.id
  key    = "assets/images"
}

resource "aws_s3_bucket_object" "webfonts_folder" {
  bucket = aws_s3_bucket.serverless_bucket2.id
  key    = "assets/webfonts"
}

locals {
  s3_origin_id = "myS3Origin"
}

resource "aws_acm_certificate" "cert" {
  
}

resource "aws_cloudfront_distribution" "cloudfront-distribution2" {
  comment = "CDN with S3 dns Origin"
  enabled = true
  is_ipv6_enabled = true
  price_class = "PriceClass_All"
  retain_on_delete = false
  default_root_object = "index.html"
  aliases = []

  origin {
    domain_name = "${var.s3_bucket_name}.s3.amazonaws.com"
    origin_id   = "S3-${var.s3_bucket_name}"
  }

  default_cache_behavior {
    allowed_methods        = ["GET","HEAD"]
    cached_methods         = ["GET","HEAD"]
    compress               = false
    default_ttl            = 0
    max_ttl                = 0
    min_ttl                = 0
    smooth_streaming       = false
    target_origin_id       = "S3-${var.s3_bucket_name}"
    trusted_signers        = []
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  ordered_cache_behavior {
    allowed_methods        = ["GET","HEAD"]
    cached_methods         = ["GET","HEAD"]
    compress               = false
    default_ttl            = 0
    max_ttl                = 0
    min_ttl                = 0
    path_pattern           = "/assets"
    smooth_streaming       = false
    target_origin_id       = "S3-${var.s3_bucket_name}"
    trusted_signers        = []
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1"
  }

  tags = {
    Name = "${var.product_name}-cdn"
    Application = var.business_name
    Desc = "CDN for ${var.product_name}"
  }
}
