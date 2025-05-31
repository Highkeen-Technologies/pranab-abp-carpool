# Reference an existing IAM role named "ecsInstanceRole"
# data "aws_iam_role" "ecs_instance_role" {
#   name = "ecsInstanceRole"
# }

# Optionally attach the ECS EC2 policy if not already attached
# resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy" {
#   role       = data.aws_iam_role.ecs_instance_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
# }

# Create an instance profile using the existing IAM role
# resource "aws_iam_instance_profile" "ecs_instance_profile" {
#   name = "ecsInstanceProfile"
#   role = data.aws_iam_role.ecs_instance_role.name
# }


resource "aws_iam_role" "ecs_instance_role" {
  name = "ecsInstanceRole-carpool"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecsInstanceProfile"
  role = aws_iam_role.ecs_instance_role.name
}

