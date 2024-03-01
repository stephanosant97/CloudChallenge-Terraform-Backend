#ACM certificate
resource "aws_acm_certificate" "sscloudresumeweb" {
  domain_name       = "*.stephanosant.com"
  validation_method = "DNS"

  tags = {
    Name = "resume-certificate"
  }
}