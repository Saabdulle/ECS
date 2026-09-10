resource "aws_security_group" "rabbitmq_sg" {
  name        = "${var.project_name}-rabbitmq-sg"
  description = "Allow RabbitMQ traffic from ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow AMQP from ECS tasks"
    from_port       = 5672
    to_port         = 5672
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
    Name = "${var.project_name}-rabbitmq-sg"
  }
}

resource "aws_ecs_task_definition" "rabbitmq" {
  family                   = "${var.project_name}-rabbitmq"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = "256"
  memory = "512"

  execution_role_arn = var.ecs_execution_role_arn
  task_role_arn      = var.ecs_task_role_arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  container_definitions = jsonencode([
    {
      name      = "rabbitmq"
      image     = "rabbitmq:3.13-management-alpine"
      essential = true

      portMappings = [
        {
          containerPort = 5672
          hostPort      = 5672
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "RABBITMQ_DEFAULT_USER"
          value = var.rabbitmq_username
        },
        {
          name  = "RABBITMQ_DEFAULT_PASS"
          value = var.rabbitmq_password
        },
        {
          name  = "RABBITMQ_DEFAULT_VHOST"
          value = "plane"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = var.cloudwatch_log_group_name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "rabbitmq"
        }
      }
    }
  ])

  tags = {
    Name = "${var.project_name}-rabbitmq-task"
  }
}

resource "aws_ecs_service" "rabbitmq" {
  name            = "${var.project_name}-rabbitmq-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.rabbitmq.arn

  desired_count = 1
  launch_type   = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.rabbitmq_sg.id]
    assign_public_ip = false
  }
  service_registries {
    registry_arn = aws_service_discovery_service.rabbitmq.arn
  }

  tags = {
    Name = "${var.project_name}-rabbitmq-service"
  }
}

resource "aws_service_discovery_private_dns_namespace" "plane" {
  name = "${var.project_name}.local"
  vpc  = var.vpc_id

  tags = {
    Name = "${var.project_name}-namespace"
  }
}

resource "aws_service_discovery_service" "rabbitmq" {
  name = "rabbitmq"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.plane.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }
    tags = {
    Name = "${var.project_name}-rabbitmq-discovery"
  }
}