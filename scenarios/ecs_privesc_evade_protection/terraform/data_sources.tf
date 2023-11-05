data "aws_caller_identity" "current" {}

# Search based on tag to get the IP of EC2 that is automatically generated by ASG.
data "aws_instances" "asg_instance" {
  depends_on = [time_sleep.wait_for_instance]

  instance_tags = {
    Name = "cg-ec2-instance-${var.cgid}"
  }
}

data "aws_availability_zones" "current_az" {
  state = "available"
}

# Get AMI of the latest version of Amazon Linux 2 for ECS.
data "aws_ami" "latest_amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

# EC2 is located in the default VPC.
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "all_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# compress index.py to lambda.zip
data "archive_file" "lambda_zip" {
  type             = "zip"
  source_file      = "./index.py"
  output_file_mode = "0666"
  output_path      = "./lambda.zip"
}