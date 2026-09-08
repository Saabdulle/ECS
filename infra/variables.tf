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

