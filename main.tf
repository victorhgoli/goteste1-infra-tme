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


module "vpc" {
  source = "./vpc"
  name_prefix = var.name_prefix
}

module "ecs" {
  source = "./ecs"
  name_prefix = var.name_prefix
  vpc = module.vpc.vpc
  subnets = module.vpc.subnets
  ecs_cluster_name = var.ecs_cluster_name
  certificate_arn = var.certificate_arn
  domain_name = var.domain_name
  subdomain_url = var.subdomain_url
}

module "task_execution_role" {
  source = "./task-execution-role"
  name_prefix = var.name_prefix
}

/*
resource "aws_key_pair" "my_key_pair" {
  key_name   = "my-key-pair"  # Replace with the desired key pair name
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDWdn2/te6Ryx8Fesc4SfceF/yHIn2MWqnFeYxAr0jUs9oS9msB2hRYUnmucpr8nPwkZBtTSR2ZzF8VuaEO50Cpq6Mror25gyR9FRgIAxgfk4o7bOHj5JnjKB1/jZta0JuWe7CcH+I8tUXvbroysMSZALI5AOZPQBRMKtRTYLl2dY3LMVjtg1ei6U/GEsmJBC9CTFf5zHbOWYtsYPcfNsfrWWn6oct47CDRG2O9UFPobojqFMUOyFpXHrqBmbUdc4ZXfDj/FIjEBLYhFQUDp12sKKrKo8nCpUwGQ54hHumT2q+mcce9R09RF4AH43Fk7krcGKsYNmiE6ASJy6wFxfkgOknlW4VRNET5ulMJ2WLzImxvTzPXumfhoZivoYjQtxRZHZ8t4XB/gQdMVrqFt2a0qSOug0riNIToWqwDQIPWw08Oa9hrU/eUmUZ3pc33OYAtmBkPPCMsWs1F3J6MQmE5BatvWiow7P/6i6zUloszYtc6o1/v21TqTfDWou2u1EOslqEYtpGbiDbi4N4sc5Adog+HhZQ5we0BRJaMUUqMUYJrBivrx41KvUQ5TJxYaP+S/s0WfBXD2AVJANnmZbJyIFKoRPgsm5oGwHsWCaYz2zJfuwZgsT+a92R+99jGO0lM8aIpUymZKRFwjObs8yzwWbylBspHZd3QTJxoXAQgMw== your_email@example.com"
}*/



