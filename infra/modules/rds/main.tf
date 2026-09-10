resource "aws_db_subnet_group" "plane_db_subnet_group" {
  name       = "${var.project_name}-rds-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "${var.project_name}-rds-subnet-group"
    Environment = var.project_name
  }
}

resource "aws_security_group" "plane_rds_sg" {
  name        = "${var.project_name}-rds-sg"
  description = "Security group for RDS instance access from ECS"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow RDS access from ECS"
    from_port       = 5432
    to_port         = 5432
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
    Name = "${var.project_name}-rds-sg"
  }
}

resource "aws_db_instance" "plane_postgres" {
  identifier = "${var.project_name}-rds-instance"


  engine                = "postgres"
  engine_version        = "15"
  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  max_allocated_storage = 50
  storage_type          = "gp3"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = 5432

  db_subnet_group_name   = aws_db_subnet_group.plane_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.plane_rds_sg.id]

  publicly_accessible = false
  multi_az            = false

  storage_encrypted       = true
  backup_retention_period = 1

  skip_final_snapshot      = true
  delete_automated_backups = false

  tags = {
    Name        = "${var.project_name}-postgres-db"
    Environment = var.project_name
  }
}