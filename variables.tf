variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-south-1"
}
variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "ecr_repo_name" {
  description = "ECR repo name"
  type        = string
}
