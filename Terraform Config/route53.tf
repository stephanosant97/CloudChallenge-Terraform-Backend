#Route 53 zone
resource "aws_route53_zone" "primary" {
  name = "stephanosant.com"
}

#Route 53 records
resource "aws_route53_record" "cloudfront_alias" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "www.stephanosant.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdndistro.domain_name
    zone_id                = aws_cloudfront_distribution.cdndistro.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloudfront_alias2" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "*.stephanosant.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdndistro.domain_name
    zone_id                = aws_cloudfront_distribution.cdndistro.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "acm_validation" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "_44093e1c5638b2967449a14bebdee226.stephanosant.com"
  type    = "CNAME"
  ttl     = 300

  records = ["_dde56ff69dae1d261e61c787196a75ea.mhbtsbpdnt.acm-validations.aws."]
}

resource "aws_route53_record" "name_servers" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "stephanosant.com"
  type    = "NS"
  ttl     = 172800

  records = ["ns-1149.awsdns-15.org.", "ns-1818.awsdns-35.co.uk.", "ns-477.awsdns-59.com.", "ns-745.awsdns-29.net."]
}

resource "aws_route53_record" "start_of_authority" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "stephanosant.com"
  type    = "SOA"
  ttl     = 900

  records = ["ns-477.awsdns-59.com. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400"]
}