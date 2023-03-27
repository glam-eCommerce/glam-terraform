# Configure the AWS provider
provider "aws" {
  region = "ap-southeast-1"
}

# Define the Elastic Beanstalk application and environment for the frontend
resource "aws_elastic_beanstalk_application" "frontend_app" {
  name = "glam-docker-client-eb"
}

resource "aws_elastic_beanstalk_environment" "frontend_staging_env" {
  name                = "Glamdockerclienteb-env-staging"
  application         = aws_elastic_beanstalk_application.frontend_app.name
  solution_stack_name = "64bit Amazon Linux 2 v5.4.6 running Docker 20.10.7"
  
  # Configure the Elastic Beanstalk environment with the necessary properties for the frontend code
  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "Command"
    value     = "docker run --env-file /opt/elasticbeanstalk/deployment/env -p 80:80 -d <your-docker-image>"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "NODE_ENV"
    value     = "production"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "REACT_APP_API_URL"
    value     = "http://glamdockerservereb-env-staging.eba-eemfywtm.ap-southeast-1.elasticbeanstalk.com"
  }
  
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DD_AGENT_MAJOR_VERSION"
    value     = "7"
  }
  
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DD_AGENT_MINOR_VERSION"
    value     = ""
  }
  
  # Set up the CodePipeline for the frontend
  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "CodePipelineServiceRoleArn"
    value     = var.frontend_codepipeline_role_arn
  }
  
  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "CodePipelineS3Bucket"
    value     = var.frontend_codepipeline_s3_bucket_name
  }
  
  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "CodePipelineS3Key"
    value     = var.frontend_codepipeline_s3_key
  }
}

# Define the Elastic Beanstalk application and environment for the backend
resource "aws_elastic_beanstalk_application" "backend_app" {
  name = "glam-shop-server"
}

resource "aws_elastic_beanstalk_environment" "backend_staging_env" {
  name                = "glam-shop-server-staging"
  application         = aws_elastic_beanstalk_application.backend_app.name
  solution_stack_name = "64bit Amazon Linux 2 v5.4.6 running Docker 20.10.7"
  
  # Configure the Elastic Beanstalk environment with the necessary properties for the backend code
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DATABASE_URL"
    value     = var.backend_db_url
  }
  
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DATABASE_NAME"
    value     = var.backend_db_name
  }
  
  # Set up the CodePipeline for the backend
  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "CodePipelineServiceRoleArn"
    value     = var.backend_codepipeline_role_arn
  }
  
  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "CodePipelineS3Bucket"
    value     = var.backend_codepipeline_s3_bucket_name
  }
  
  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "CodePipelineS3Key"
    value     = var.backend_codepipeline_s3_key
  }
}

# Define the DataDog configuration
resource "datadog_dashboard" "
