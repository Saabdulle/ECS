variable "project_name" {
  description = "Project name"
  type        = string
}

variable "domain_name" {
  description = "Application domain name"
  type        = string
}
variable "route53_zone_id" {
  description = "Route53 zone ID for the domain"
  type        = string
}