resource "aws_ecs_task_definition" "api" {
  family                   = "${var.project_name}-api"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = "512"
  memory = "1024"

  execution_role_arn = aws_iam_role.ecs_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  container_definitions = jsonencode([
    {
      name      = "api"
      image     = "${var.ecr_repository_url}:api-0.0.1"
      essential = true

      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "DATABASE_URL"
          value = "postgresql://${var.db_username}:${var.db_password}@${var.db_endpoint}:${var.db_port}/${var.db_name}"
        },
        {
          name  = "REDIS_URL"
          value = "redis://${var.redis_endpoint}:${var.redis_port}/"
        },
        {
          name  = "AMQP_URL"
          value = "amqp://${var.rabbitmq_username}:${var.rabbitmq_password}@${var.rabbitmq_host}:5672/plane"
        },
        {
          name  = "SECRET_KEY"
          value = var.secret_key
        },
        {
          name  = "AWS_REGION"
          value = var.aws_region
        },
        {
          name  = "AWS_S3_BUCKET_NAME"
          value = var.s3_bucket_name
        },
        {
          name  = "GUNICORN_WORKERS"
          value = "2"
        },
        {
          name  = "WEB_URL"
          value = "https://${var.domain_name}"
        },
        {
          name  = "APP_BASE_URL"
          value = "https://${var.domain_name}"
        },
        {
          name  = "ADMIN_BASE_URL"
          value = "https://${var.domain_name}"
        },
        {
          name  = "SPACE_BASE_URL"
          value = "https://${var.domain_name}"
        },
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "api"
        }
      }
    }
  ])

  tags = {
    Name = "${var.project_name}-api-task"
  }
}

resource "aws_ecs_service" "api" {
  name            = "${var.project_name}-api-service"
  cluster         = aws_ecs_cluster.plane_ecs_cluster.id
  task_definition = aws_ecs_task_definition.api.arn

  desired_count = 1
  launch_type   = "FARGATE"

  health_check_grace_period_seconds = 120

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.api_target_group_arn
    container_name   = "api"
    container_port   = 8000
  }

  tags = {
    Name = "${var.project_name}-api-service"
  }
}

resource "aws_ecs_task_definition" "migrator" {
  family                   = "${var.project_name}-migrator"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = "512"
  memory = "1024"

  execution_role_arn = aws_iam_role.ecs_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  container_definitions = jsonencode([
    {
      name      = "migrator"
      image     = "${var.ecr_repository_url}:api-0.0.1"
      essential = true

      command = [
        "/bin/sh",
        "-c",
        "/code/bin/docker-entrypoint-migrator.sh"
      ]

      environment = [
        {
          name  = "DATABASE_URL"
          value = "postgresql://${var.db_username}:${var.db_password}@${var.db_endpoint}:${var.db_port}/${var.db_name}"
        },
        {
          name  = "REDIS_URL"
          value = "redis://${var.redis_endpoint}:${var.redis_port}/"
        },
        {
          name  = "AMQP_URL"
          value = "amqp://${var.rabbitmq_username}:${var.rabbitmq_password}@${var.rabbitmq_host}:5672/plane"
        },
        {
          name  = "SECRET_KEY"
          value = var.secret_key
        },
        {
          name  = "AWS_REGION"
          value = var.aws_region
        },
        {
          name  = "AWS_S3_BUCKET_NAME"
          value = var.s3_bucket_name
        },
        {
          name  = "WEB_URL"
          value = "https://${var.domain_name}"
        },
        {
          name  = "APP_BASE_URL"
          value = "https://${var.domain_name}"
        },
        {
          name  = "ADMIN_BASE_URL"
          value = "https://${var.domain_name}"
        },
        {
          name  = "SPACE_BASE_URL"
          value = "https://${var.domain_name}"
        },
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "migrator"
        }
      }
    }
  ])

  tags = {
    Name = "${var.project_name}-migrator-task"
  }
}

resource "aws_ecs_task_definition" "worker" {
  family                   = "${var.project_name}-worker"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = "512"
  memory = "1024"

  execution_role_arn = aws_iam_role.ecs_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  container_definitions = jsonencode([
    {
      name      = "worker"
      image     = "${var.ecr_repository_url}:api-0.0.1"
      essential = true

      command = [
        "./bin/docker-entrypoint-worker.sh"
      ]

      environment = [
        {
          name  = "DATABASE_URL"
          value = "postgresql://${var.db_username}:${var.db_password}@${var.db_endpoint}:${var.db_port}/${var.db_name}"
        },
        {
          name  = "REDIS_URL"
          value = "redis://${var.redis_endpoint}:${var.redis_port}/"
        },
        {
          name  = "AMQP_URL"
          value = "amqp://${var.rabbitmq_username}:${var.rabbitmq_password}@${var.rabbitmq_host}:5672/plane"
        },
        {
          name  = "SECRET_KEY"
          value = var.secret_key
        },
        {
          name  = "AWS_REGION"
          value = var.aws_region
        },
        {
          name  = "AWS_S3_BUCKET_NAME"
          value = var.s3_bucket_name
        },
        {
          name  = "WEB_URL"
          value = "https://${var.domain_name}"
        },
        {
          name  = "APP_BASE_URL"
          value = "https://${var.domain_name}"
        },
        {
          name  = "ADMIN_BASE_URL"
          value = "https://${var.domain_name}"
        },
        {
          name  = "SPACE_BASE_URL"
          value = "https://${var.domain_name}"
        },
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "worker"
        }
      }
    }
  ])

  tags = {
    Name = "${var.project_name}-worker-task"
  }
}

resource "aws_ecs_service" "worker" {
  name            = "${var.project_name}-worker-service"
  cluster         = aws_ecs_cluster.plane_ecs_cluster.id
  task_definition = aws_ecs_task_definition.worker.arn

  desired_count = 1
  launch_type   = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  tags = {
    Name = "${var.project_name}-worker-service"
  }
}

resource "aws_ecs_task_definition" "beat_worker" {
  family                   = "${var.project_name}-beat-worker"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = "256"
  memory = "512"

  execution_role_arn = aws_iam_role.ecs_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  container_definitions = jsonencode([
    {
      name      = "beat-worker"
      image     = "${var.ecr_repository_url}:api-0.0.1"
      essential = true

      command = [
        "./bin/docker-entrypoint-beat.sh"
      ]

      environment = [
        {
          name  = "DATABASE_URL"
          value = "postgresql://${var.db_username}:${var.db_password}@${var.db_endpoint}:${var.db_port}/${var.db_name}"
        },
        {
          name  = "REDIS_URL"
          value = "redis://${var.redis_endpoint}:${var.redis_port}/"
        },
        {
          name  = "AMQP_URL"
          value = "amqp://${var.rabbitmq_username}:${var.rabbitmq_password}@${var.rabbitmq_host}:5672/plane"
        },
        {
          name  = "SECRET_KEY"
          value = var.secret_key
        },
        {
          name  = "AWS_REGION"
          value = var.aws_region
        },
        {
          name  = "AWS_S3_BUCKET_NAME"
          value = var.s3_bucket_name
        },
        {
          name  = "WEB_URL"
          value = "https://${var.domain_name}"
        },
        {
          name  = "APP_BASE_URL"
          value = "https://${var.domain_name}"
        },
        {
          name  = "ADMIN_BASE_URL"
          value = "https://${var.domain_name}"
        },
        {
          name  = "SPACE_BASE_URL"
          value = "https://${var.domain_name}"
        },
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "beat-worker"
        }
      }
    }
  ])

  tags = {
    Name = "${var.project_name}-beat-worker-task"
  }
}

resource "aws_ecs_service" "beat_worker" {
  name            = "${var.project_name}-beat-worker-service"
  cluster         = aws_ecs_cluster.plane_ecs_cluster.id
  task_definition = aws_ecs_task_definition.beat_worker.arn

  desired_count = 1
  launch_type   = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  tags = {
    Name = "${var.project_name}-beat-worker-service"
  }
}

resource "aws_ecs_task_definition" "live" {
  family                   = "${var.project_name}-live"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = "256"
  memory = "512"

  execution_role_arn = aws_iam_role.ecs_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  container_definitions = jsonencode([
    {
      name      = "live"
      image     = "${var.ecr_repository_url}:live-0.0.1"
      essential = true

      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "API_BASE_URL"
          value = "https://tm.saeedproject.com"
        },
        {
          name  = "LIVE_SERVER_SECRET_KEY"
          value = var.live_server_secret_key
        },
        {
          name  = "REDIS_URL"
          value = "redis://${var.redis_endpoint}:${var.redis_port}/"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "live"
        }
      }
    }
  ])

  tags = {
    Name = "${var.project_name}-live-task"
  }
}

resource "aws_ecs_service" "live" {
  name            = "${var.project_name}-live-service"
  cluster         = aws_ecs_cluster.plane_ecs_cluster.id
  task_definition = aws_ecs_task_definition.live.arn

  desired_count = 1
  launch_type   = "FARGATE"

  health_check_grace_period_seconds = 120

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.live_target_group_arn
    container_name   = "live"
    container_port   = 3000
  }

  tags = {
    Name = "${var.project_name}-live-service"
  }
}