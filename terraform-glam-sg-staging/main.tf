provider "aws" {
  region = "ap-southeast-1"
}
# Elastic Beanstalk for frontend
module "frontend_eb" {
  source = "terraform-aws-modules/elastic-beanstalk/aws"

  name        = "my-frontend-staging"
  application = "my-frontend-app"
  environment = "staging"
  solution_stack_name = "64bit Amazon Linux 2 v5.4.7 running Docker 19.03.13-ce"

  # Specify the frontend Docker image
  container_definitions_json = jsonencode([
    {
      name = "my-frontend-container"
      image = "my-frontend-image:latest"
      portMappings = [
        {
          containerPort = 80
          hostPort = 80
        }
      ]
    }
  ])

# Elastic Beanstalk for backend
module "backend_eb" {
  source = "terraform-aws-modules/elastic-beanstalk/aws"

  name        = "my-backend-staging"
  application = "my-backend-app"
  environment = "staging"
  solution_stack_name = "64bit Amazon Linux 2 v5.4.7 running Docker 19.03.13-ce"

  # Specify the backend Docker image
  container_definitions_json = jsonencode([
    {
      name = "my-backend-container"
      image = "my-backend-image:latest"
      portMappings = [
        {
          containerPort = 3000
          hostPort = 3000
        }
      ]
    }
  ])

  # Connect to the MongoDB instance
  setting = [
    {
      namespace = "aws:elasticbeanstalk:application:environment"
      name      = "MONGO_URI"
      value     = "mongodb://username:password@mongodb-instance.mongodb.net/mydatabase"
    }
  ]
}

# DataDog configuration
module "datadog" {
  source = "terraform-aws-modules/datadog/aws"
  datadog_api_key = var.datadog_api_key
  datadog_app_key = var.datadog_app_key

  # Monitor Elastic Beanstalk instances
  monitor_aws_elastic_beanstalk = true
}
