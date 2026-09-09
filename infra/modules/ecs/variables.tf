variable "project_name" {
  description = "Project name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs used by ECS tasks"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID of the ALB"
  type        = string
}

variable "ecr_repository_url" {
  description = "ECR repository URL"
  type        = string
}

variable "web_target_group_arn" {
  description = "Web target group ARN"
  type        = string
}

variable "admin_target_group_arn" {
  description = "Admin target group ARN"
  type        = string
}

variable "space_target_group_arn" {
  description = "Space target group ARN"
  type        = string
}

variable "api_target_group_arn" {
  description = "API target group ARN"
  type        = string
}

variable "live_target_group_arn" {
  description = "Live target group ARN"
  type        = string
}

variable "web_image_tag" {
  description = "Web image tag"
  type        = string
  default     = "web-0.0.1"
}

variable "admin_image_tag" {
  description = "Admin image tag"
  type        = string
  default     = "admin-0.0.1"
}

variable "space_image_tag" {
  description = "Space image tag"
  type        = string
  default     = "space-0.0.1"
}

variable "api_image_tag" {
  description = "API image tag"
  type        = string
  default     = "api-0.0.1"
}

variable "live_image_tag" {
  description = "Live image tag"
  type        = string
  default     = "live-0.0.1"
}