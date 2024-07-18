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
  ingress {
    from_port   = 5557
    to_port     = 5557
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

# Locust Master
resource "aws_ecs_task_definition" "ecs_task_master" {
  family                   = "${var.project}-ecs-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "${var.project}-locust-master",
      image = "locustio/locust:${var.ecs_task_locust_version}"
      "command" = [
        "--master",
        "-f",
        "/mnt/efs/${var.ecs_task_locust_file}"
      ]
      essential = true
      portMappings = [
        {
          containerPort = 8089
          hostPort      = 8089
        },
        {
          containerPort = 5557
          hostPort      = 5557
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
      transit_encryption_port = 2998

      authorization_config {
        access_point_id = aws_efs_access_point.efs_ap.id
        iam             = "ENABLED"
      }
    }
  }
}

resource "aws_ecs_service" "ecs_service_master" {
  name            = "${var.project}-ecs-service-master"
  cluster         = data.aws_ecs_cluster.ecs_cluster.arn
  task_definition = aws_ecs_task_definition.ecs_task_master.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  lifecycle {
    ignore_changes = [
      desired_count
    ]
  }

  network_configuration {
    subnets         = data.aws_subnets.private_subnet.ids
    security_groups = [aws_security_group.ecs_sg.id]

  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_lb_tg.arn
    container_name   = "${var.project}-locust-master"
    container_port   = 8089
  }

  depends_on = [
    aws_lb_listener.http
  ]

  service_registries {
    registry_arn = aws_service_discovery_service.discovery_service.arn
  }
}


# Locust Worker

resource "aws_ecs_task_definition" "ecs_task_worker" {
  family                   = "${var.project}-ecs-task-worker"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "${var.project}-locust-worker",
      image = "locustio/locust:${var.ecs_task_locust_version}"
      "command" = [
        "--worker",
        "--master-host=${aws_service_discovery_service.discovery_service.name}.${aws_service_discovery_private_dns_namespace.discovery_namespace.name}",
        "-f",
        "/mnt/efs/${var.ecs_task_locust_file}",
        "-H",
        "https://randomuser.me"
      ]
      essential = true
      portMappings = [
        {
          containerPort = 8088
          hostPort      = 8088
        }
      ]
      environment = [
        {
          "name" : "LOCUST_MODE",
          "value" : "slave"
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
      transit_encryption_port = 2998

      authorization_config {
        access_point_id = aws_efs_access_point.efs_ap.id
        iam             = "ENABLED"
      }
    }
  }
}

resource "aws_ecs_service" "ecs_service_worker" {
  name            = "${var.project}-ecs-service-worker"
  cluster         = data.aws_ecs_cluster.ecs_cluster.arn
  task_definition = aws_ecs_task_definition.ecs_task_worker.arn
  desired_count   = var.ecs_task_worker_desire
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = data.aws_subnets.private_subnet.ids
    security_groups = [aws_security_group.ecs_sg.id]
  }

  lifecycle {
    ignore_changes = [
      desired_count
    ]
  }
}

