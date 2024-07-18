resource "aws_appautoscaling_target" "ecs_worker_target" {
  min_capacity       = var.ecs_task_worker_min
  max_capacity       = var.ecs_task_worker_max
  resource_id        = "service/${data.aws_ecs_cluster.ecs_cluster.cluster_name}/${aws_ecs_service.ecs_service_worker.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_worker_policy_memory" {
  name               = "ecs_worker_policy_memory"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_worker_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_worker_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_worker_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value = 80
  }
}


resource "aws_appautoscaling_policy" "ecs_worker_policy_cpu" {
  name               = "ecs_worker_policy_cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_worker_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_worker_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_worker_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 60
  }
}
