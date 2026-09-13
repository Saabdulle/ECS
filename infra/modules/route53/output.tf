output "zone_id" {
  value = aws_route53_zone.plane_hosted_zone.zone_id
}

output "name_servers" {
  value = aws_route53_zone.plane_hosted_zone.name_servers
}