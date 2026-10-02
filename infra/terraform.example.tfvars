aws_region   = "eu-west-2"
aws_profile  = "your-aws-profile"
project_name = "plane"

vpc_cidr = "10.0.0.0/16"

public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24",
  "10.0.3.0/24"
]

private_subnet_cidrs = [
  "10.0.4.0/24",
  "10.0.5.0/24",
  "10.0.6.0/24"
]

availability_zones = [
  "eu-west-2a",
  "eu-west-2b",
  "eu-west-2c"
]

domain_name = "plane.example.com"

web_image_tag   = "YOUR_WEB_IMAGE_TAG"
admin_image_tag = "YOUR_ADMIN_IMAGE_TAG"
space_image_tag = "YOUR_SPACE_IMAGE_TAG"
api_image_tag  = "YOUR_API_IMAGE_TAG"
live_image_tag = "YOUR_LIVE_IMAGE_TAG"

db_name     = "plane"
db_username = "DATABASE_USERNAME"
db_password = "DATABASE_PASSWORD"

rabbitmq_username = "RabbitMQ_USERNAME"
rabbitmq_password = "RABBITMQ_PASSWORD"

secret_key = "APPLICATION_SECRET_KEY"

live_server_secret_key = "LIVE_SERVER_SECRET_KEY"