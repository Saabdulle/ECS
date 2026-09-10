resource "aws_elasticache_subnet_group" "plane_redis_subnet_group" {
  name       = "${var.project_name}-redis-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-redis-subnet-group"
  }
}

resource "aws_security_group" "plane_redis_sg" {
  name        = "${var.project_name}-redis-sg"
  description = "Allow Valkey access from ECS"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow Valkey access from ECS"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [var.ecs_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-redis-sg"
  }
}

resource "aws_elasticache_replication_group" "plane_redis" {
  replication_group_id = "${var.project_name}-redis"
  description          = "Valkey cache for Plane"

  engine             = "valkey"
  node_type          = "cache.t4g.micro"
  num_cache_clusters = 1
  port               = 6379

  subnet_group_name  = aws_elasticache_subnet_group.plane_redis_subnet_group.name
  security_group_ids = [aws_security_group.plane_redis_sg.id]

  automatic_failover_enabled = false
  multi_az_enabled           = false

  tags = {
    Name = "${var.project_name}-redis"
  }
}