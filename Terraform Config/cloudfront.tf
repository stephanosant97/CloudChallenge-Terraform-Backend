#cdn distro for site from s3
resource "aws_cloudfront_distribution" "cdndistro" {
  aliases = ["*.stephanosant.com", "www.stephanosant.com"]

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cache_policy_id        = "${aws_cloudfront_cache_policy.cdncache1.id}"
    cached_methods         = ["GET", "HEAD"]
    compress               = "true"
    default_ttl            = "0"
    max_ttl                = "0"
    min_ttl                = "0"
    smooth_streaming       = "false"
    target_origin_id       = "sscloudresume.s3.us-east-2.amazonaws.com" #switch to appropriate bucket name
    viewer_protocol_policy = "redirect-to-https"
  }

  default_root_object = "index.html"
  enabled             = "true"
  http_version        = "http2"
  is_ipv6_enabled     = "true"

  origin {
    connection_attempts = "3"
    connection_timeout  = "10"
    domain_name         = "sscloudresume.s3.us-east-2.amazonaws.com" #switch to appropriate bucket name
    origin_id           = "sscloudresume.s3.us-east-2.amazonaws.com" #switch to appropriate bucket name

    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/E18ZO43L3H2G89"
    }
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  retain_on_delete = "false"

  viewer_certificate {
    acm_certificate_arn            = "arn:aws:acm:us-east-1:132951925356:certificate/e4b3e829-f179-48e5-b3cb-674aec30b82d" #update to newly created cert
    cloudfront_default_certificate = "false"
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }
}

#cache policies
resource "aws_cloudfront_cache_policy" "cdncache1" {
  comment     = "Policy for Elemental MediaPackage Origin"
  default_ttl = "86400"
  max_ttl     = "31536000"
  min_ttl     = "0"
  name        = "Elemental-MediaPackage"

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }

    enable_accept_encoding_brotli = "false"
    enable_accept_encoding_gzip   = "true"

    headers_config {
      header_behavior = "whitelist"

      headers {
        items = ["origin"]
      }
    }

    query_strings_config {
      query_string_behavior = "whitelist"

      query_strings {
        items = ["aws.manifestfilter", "end", "m", "start"]
      }
    }
  }
}

resource "aws_cloudfront_cache_policy" "cdncache2" {
  comment     = "Policy for Amplify Origin"
  default_ttl = "2"
  max_ttl     = "600"
  min_ttl     = "2"
  name        = "Amplify"

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "all"
    }

    enable_accept_encoding_brotli = "true"
    enable_accept_encoding_gzip   = "true"

    headers_config {
      header_behavior = "whitelist"

      headers {
        items = ["Authorization", "CloudFront-Viewer-Country", "Host"]
      }
    }

    query_strings_config {
      query_string_behavior = "all"
    }
  }
}

resource "aws_cloudfront_cache_policy" "cdncahce3" {
  comment     = "Policy with caching disabled"
  default_ttl = "0"
  max_ttl     = "0"
  min_ttl     = "0"
  name        = "CachingDisabled"

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }

    enable_accept_encoding_brotli = "false"
    enable_accept_encoding_gzip   = "false"

    headers_config {
      header_behavior = "none"
    }

    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

resource "aws_cloudfront_cache_policy" "cdncache4" {
  comment     = "Policy with caching enabled. Supports Gzip and Brotli compression."
  default_ttl = "86400"
  max_ttl     = "31536000"
  min_ttl     = "1"
  name        = "CachingOptimized"

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }

    enable_accept_encoding_brotli = "true"
    enable_accept_encoding_gzip   = "true"

    headers_config {
      header_behavior = "none"
    }

    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

resource "aws_cloudfront_cache_policy" "cdncache5" {
  comment     = "Default policy when compression is disabled"
  default_ttl = "86400"
  max_ttl     = "31536000"
  min_ttl     = "1"
  name        = "CachingOptimizedForUncompressedObjects"

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }

    enable_accept_encoding_brotli = "false"
    enable_accept_encoding_gzip   = "false"

    headers_config {
      header_behavior = "none"
    }

    query_strings_config {
      query_string_behavior = "none"
    }
  }
}