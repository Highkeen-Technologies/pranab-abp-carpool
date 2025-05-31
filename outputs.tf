output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "autoscaling_group_name" {
  value = aws_autoscaling_group.ecs.name
}
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.carpool.dns_name
}

output "alb_name" {
  description = "Name of the Application Load Balancer"
  value       = aws_lb.carpool.name
}
