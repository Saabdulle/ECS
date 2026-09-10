output "db_endpoint" {
  value = aws_db_instance.plane_postgres.endpoint
}
output "db_port" {
  value = aws_db_instance.plane_postgres.port
}
output "db_name" {
  value = aws_db_instance.plane_postgres.db_name
}
output "db_security_group_id" {
  value = aws_db_instance.plane_postgres.vpc_security_group_ids
}