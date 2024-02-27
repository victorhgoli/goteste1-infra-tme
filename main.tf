terraform {
  backend "s3" {
    bucket = "tme-infra-terraform-state"
    key    = "goteste1/state/terraform.tfstate"
    region = "us-east-1"
  }
}


// Defina o provedor de infraestrutura
provider "aws" {
  region = "us-east-1"

}


# --- ECS Node Role ---

data "aws_iam_policy_document" "ecs_node_doc" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_node_role" {
  name_prefix        = "demo-ecs-node-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_node_doc.json
}

resource "aws_iam_role_policy_attachment" "ecs_node_role_policy" {
  role       = aws_iam_role.ecs_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_node" {
  name_prefix = "demo-ecs-node-profile"
  path        = "/ecs/instance/"
  role        = aws_iam_role.ecs_node_role.name
}



resource "aws_instance" "my_instance" {
  ami           = "ami-0440d3b780d96b29d"  # Replace with the desired AMI ID
  instance_type = "t2.micro"
  key_name      = "my-key-pair"   # Replace with the name of your key pair
  vpc_security_group_ids = "sg-0027e71e382a34829"

  associate_public_ip_address = true

  iam_instance_profile = "ecsInstanceRole" 

  user_data = <<-USERDATA
              #!/bin/bash
              echo ECS_CLUSTER=my-ecs-cluster >> /etc/ecs/ecs.config
              USERDATA

  tags = {
    Name = "my-ecs-instance"
  }
}

resource "aws_ecs_cluster" "my_cluster" {
  name = "my-ecs-cluster"

  depends_on = [ aws_instance.my_instance ]
}


resource "aws_ecs_task_definition" "my_task_definition" {
  family                   = "my-task-definition"
  network_mode             = "awsvpc"
  container_definitions    = <<DEFINITION
[
  {
    "name": "my-container",
    "image": "590184040663.dkr.ecr.us-east-1.amazonaws.com/tme-teste-go1:latest",
    "cpu": 256,
    "memory": 512,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80,
        "protocol": "tcp"
      }
    ]
  }
]
DEFINITION
}


resource "aws_ecs_service" "my_service" {
  name            = "my-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task_definition.arn
  desired_count   = 1

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  network_configuration {
    subnets         = ["subnet-0dd736880ee2ddf01"]  # Replace with the desired subnet IDs
    security_groups = ["sg-0027e71e382a34829"]     # Replace with the desired security group IDs
  }
}


resource "aws_key_pair" "my_key_pair" {
  key_name   = "my-key-pair"  # Replace with the desired key pair name
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDWdn2/te6Ryx8Fesc4SfceF/yHIn2MWqnFeYxAr0jUs9oS9msB2hRYUnmucpr8nPwkZBtTSR2ZzF8VuaEO50Cpq6Mror25gyR9FRgIAxgfk4o7bOHj5JnjKB1/jZta0JuWe7CcH+I8tUXvbroysMSZALI5AOZPQBRMKtRTYLl2dY3LMVjtg1ei6U/GEsmJBC9CTFf5zHbOWYtsYPcfNsfrWWn6oct47CDRG2O9UFPobojqFMUOyFpXHrqBmbUdc4ZXfDj/FIjEBLYhFQUDp12sKKrKo8nCpUwGQ54hHumT2q+mcce9R09RF4AH43Fk7krcGKsYNmiE6ASJy6wFxfkgOknlW4VRNET5ulMJ2WLzImxvTzPXumfhoZivoYjQtxRZHZ8t4XB/gQdMVrqFt2a0qSOug0riNIToWqwDQIPWw08Oa9hrU/eUmUZ3pc33OYAtmBkPPCMsWs1F3J6MQmE5BatvWiow7P/6i6zUloszYtc6o1/v21TqTfDWou2u1EOslqEYtpGbiDbi4N4sc5Adog+HhZQ5we0BRJaMUUqMUYJrBivrx41KvUQ5TJxYaP+S/s0WfBXD2AVJANnmZbJyIFKoRPgsm5oGwHsWCaYz2zJfuwZgsT+a92R+99jGO0lM8aIpUymZKRFwjObs8yzwWbylBspHZd3QTJxoXAQgMw== your_email@example.com"
}



