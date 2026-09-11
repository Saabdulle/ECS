variable "aws_region" {
  description = "Local AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "aws_profile" {
  description = "Local AWS profile"
  type        = string
  default     = "plane-ecs"
}
variable "project_name" {
  description = "Project name"
  type        = string
  default     = "ecs-plane"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}

variable "domain_name" {
  description = "Application domain name"
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
variable "db_name" {
  description = "Database name"
  type        = string
}
variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}
variable "rabbitmq_username" {
  description = "RabbitMQ username"
  type        = string
}
variable "rabbitmq_password" {
  description = "RabbitMQ password"
  type        = string
  sensitive   = true
}
variable "secret_key" {
  description = "Secret key for the application"
  type        = string
  sensitive   = true
}
variable "live_server_secret_key" {
  description = "Secret key for the live server"
  type        = string
  sensitive   = true
}