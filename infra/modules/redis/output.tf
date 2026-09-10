output "redis_endpoint" {
  value = aws_elasticache_replication_group.plane_redis.primary_endpoint_address
}
output "redis_port" {
  value = aws_elasticache_replication_group.plane_redis.port
}
output "redis_security_group_id" {
  value = aws_security_group.plane_redis_sg.id
}