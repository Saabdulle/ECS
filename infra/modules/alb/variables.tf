variable "project_name" {
  description = "Project name"
  type        = string
  default     = "ecs-plane"
}
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}
variable "public_subnets_ids" {
  description = "Public subnets ids for the ALB"
  type        = list(string)
}
