resource "aws_ecs_cluster" "main" {
  name = "carpool-ecs-cluster"
}

resource "aws_ecs_task_definition" "carpool" {
  family                   = "carpool-task"
  network_mode             = "host"
  requires_compatibilities = ["EC2"]
  cpu                      = "1024"
  memory                   = "2048"

  runtime_platform {
    cpu_architecture        = "ARM64"
    operating_system_family = "LINUX"
  }

  container_definitions = jsonencode([
    {
      name      = "carpool-container"
      image     = "${var.aws_account_id}.dkr.ecr.ap-south-1.amazonaws.com/${var.ecr_repo_name}:latest"
      essential = true
      portMappings = [{
        containerPort = 80
        hostPort      = 80
        protocol      = "tcp"
      }]
    }
  ])
}

resource "aws_ecs_service" "carpool" {
  name            = "carpool-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.carpool.arn
  launch_type     = "EC2"
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.carpool.arn
    container_name   = "carpool-container"
    container_port   = 80
  }

  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 200

  depends_on = [
    aws_autoscaling_group.ecs,
    aws_lb_listener.carpool
  ]
}

resource "aws_appautoscaling_target" "carpool" {
  max_capacity       = 200
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.carpool.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "carpool_scale" {
  name               = "carpool-scale-policy"
  service_namespace  = "ecs"
  resource_id        = aws_appautoscaling_target.carpool.resource_id
  scalable_dimension = aws_appautoscaling_target.carpool.scalable_dimension
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 50.0
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}
