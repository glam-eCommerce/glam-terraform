# Configure the AWS provider
provider "aws" {
  region = "ap-southeast-1"
}

# Define the Elastic Beanstalk application and environment for the client
resource "aws_elastic_beanstalk_application" "client_app" {
  name = "Glamdockerclienteb-env-staging"
}

resource "aws_elastic_beanstalk_environment" "client_staging_env" {
  name                = "Glamdockerclienteb-env-staging"
  application         = aws_elastic_beanstalk_application.client_app.name
  solution_stack_name = "64bit Amazon Linux 2 v5.4.6 running Docker 20.10.7"
  
  # Configure the Elastic Beanstalk environment with the necessary properties for the client code

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
  
  # Set up the CodePipeline for the client
  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "CodePipelineServiceRoleArn"
    value     = var.client_codepipeline_role_arn
  }
  
  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "CodePipelineS3Bucket"
    value     = var.codepipeline_s3_bucket_name
  }
  
  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "CodePipelineS3Key"
    value     = var.client_codepipeline_s3_key
  }
}

# Define the Elastic Beanstalk application and environment for the server
resource "aws_elastic_beanstalk_application" "server_app" {
  name = "Glamdockerservereb-env-staging"
}

resource "aws_elastic_beanstalk_environment" "server_staging_env" {
  name                = "Glamdockerservereb-env-staging"
  application         = aws_elastic_beanstalk_application.server_app.name
  solution_stack_name = "64bit Amazon Linux 2 v5.4.6 running Docker 20.10.7"
  
  # Configure the Elastic Beanstalk environment with the necessary properties for the server code
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "BRAINTREE_MERCHANT_ID"
    value     = "3wv8zr3vrx5y2h8b"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "BRAINTREE_PRIVATE_KEY"
    value     = "a5df57ceeb3919851d4cd2f8c51db3a5"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "BRAINTREE_PUBLIC_KEY"
    value     = "sd25mjxk4hhw9t7r"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DATABASE"
    value     = "mongodb://root:Glamecommerce123@glam-mongodb.cf6vaav49w2p.ap-southeast-1.docdb.amazonaws.com:27017/ecommerce?tls=true&tlsCAFile=rds-combined-ca-bundle.pem&retryWrites=false"
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

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "PORT"
    value     = "80"
  }
  
  # Set up the CodePipeline for the server
  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "CodePipelineServiceRoleArn"
    value     = var.server_codepipeline_role_arn
  }
  
  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "CodePipelineS3Bucket"
    value     = var.codepipeline_s3_bucket_name
  }
  
  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "CodePipelineS3Key"
    value     = var.server_codepipeline_s3_key
  }
}

# Define the DataDog configuration
resource "datadog_dashboard" "
