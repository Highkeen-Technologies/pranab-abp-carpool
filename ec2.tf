
# Launch Template using ARM64-compatible EC2 (a1.large)
resource "aws_launch_template" "ecs" {
  name_prefix   = "ecs-ec2-"
  image_id      = data.aws_ami.ecs_ami.id
  instance_type = "a1.large"

  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=carpool-ecs-cluster >> /etc/ecs/ecs.config
  EOF
  )

  vpc_security_group_ids = [aws_security_group.ecs_sg.id]

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 30
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }
}

# Auto Scaling Group for ECS EC2 instances
resource "aws_autoscaling_group" "ecs" {
  desired_capacity = 1
  max_size         = 3
  min_size         = 1
  vpc_zone_identifier = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ] # Make sure these subnets are in ap-south-1b and ap-south-1c

  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "ecs-carpool-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

}

