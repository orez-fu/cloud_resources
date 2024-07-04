data "aws_ecs_cluster" "ecs_cluster" {
  cluster_name = "${var.project}-ecs-cluster"
}

resource "aws_security_group" "ecs_sg" {
  name        = "${var.project}-ecs-sg"
  description = "Allow all traffic to ECS service"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    from_port   = 8089
    to_port     = 8089
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "${var.project}-ecs-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "${var.project}-locust",
      image = "locustio/locust:${var.ecs_task_locust_version}"
      "command" = [
        "-f",
        "/mnt/efs/${var.ecs_task_locust_file}"
      ]
      essential = true
      portMappings = [
        {
          containerPort = 8089
          hostPort      = 8089
        }
      ]
      environment = [
        {
          "name" : "LOCUST_MODE",
          "value" : "standalone"
        }
      ]
      mountPoints = [
        {
          "sourceVolume" : "efs-volume",
          "containerPath" : "/mnt/efs"
          "readOnly" : false
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.log_group.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  volume {
    name = "efs-volume"
    efs_volume_configuration {
      file_system_id          = data.aws_efs_file_system.efs.file_system_id
      root_directory          = "/"
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2999

      authorization_config {
        access_point_id = aws_efs_access_point.efs_ap.id
        iam             = "ENABLED"
      }
    }
  }
}

resource "aws_ecs_service" "ecs_service" {
  name            = "${var.project}-ecs-service"
  cluster         = data.aws_ecs_cluster.ecs_cluster.arn
  task_definition = aws_ecs_task_definition.ecs_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = data.aws_subnets.private_subnet.ids
    security_groups = [aws_security_group.ecs_sg.id]

  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_lb_tg.arn
    container_name   = "${var.project}-locust"
    container_port   = 8089
  }

  depends_on = [
    aws_lb_listener.http
  ]
}

