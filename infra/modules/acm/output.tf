output "certificate_arn" {
  description = "ACM certificate ARN"
  value       = aws_acm_certificate.plane_cert.arn
}

output "validation_records" {
  description = "ACM certificate validation record"
  value = [
    for option in aws_acm_certificate.plane_cert.domain_validation_options : {
      name  = option.resource_record_name
      type  = option.resource_record_type
      value = option.resource_record_value
    }
  ]
}