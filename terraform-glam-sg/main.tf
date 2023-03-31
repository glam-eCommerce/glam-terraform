terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.61.0"
    }
  }
}

# Configure the AWS provider
provider "aws" {
  region = var.default_region
  access_key  = var.aws_access_key
  secret_key  = var.aws_secret_key
}

# Define the Elastic Beanstalk CLIENT application 
resource "aws_elastic_beanstalk_application" "client_app" {
  name = "glam-docker-client-eb"
}

# Define the Elastic Beanstalk for the CLIENT staging environment
resource "aws_elastic_beanstalk_environment" "client_staging_env" {
  name                = "glam-docker-client-eb-env-staging"
  application         = aws_elastic_beanstalk_application.client_app.name
  solution_stack_name = "64bit Amazon Linux 2 v5.4.6 running Docker 20.10.7"
  
  # Configure the Elastic Beanstalk environment with the necessary properties for the client code

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "NODE_ENV"
    value     = "staging"
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
  
  # setting {
  #   namespace = "aws:elasticbeanstalk:environment:process:default"
  #   name      = "CodePipelineS3Key"
  #   value     = var.client_codepipeline_s3_key
  # }
}

# Define the Elastic Beanstalk for the CLIENT production environment
resource "aws_elastic_beanstalk_environment" "client_production_env" {
  name                = "glam-docker-client-eb-env-production"
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
  
  # setting {
  #   namespace = "aws:elasticbeanstalk:environment:process:default"
  #   name      = "CodePipelineS3Key"
  #   value     = var.client_codepipeline_s3_key
  # }
}

# Define the Elastic Beanstalk application and environment for the server-staging
resource "aws_elastic_beanstalk_application" "server_app" {
  name = "glam-docker-server-eb"
}

resource "aws_elastic_beanstalk_environment" "server_staging_env" {
  name                = "glam-docker-server-eb-env-staging"
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
    value     = "${aws_docdb_cluster.glamecommerce_db_instance.endpoint}"
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
  
  # setting {
  #   namespace = "aws:elasticbeanstalk:environment:process:default"
  #   name      = "CodePipelineS3Key"
  #   value     = var.server_codepipeline_s3_key
  # }
}

# Define the DataDog configuration
# resource "datadog_dashboard" 

# Define DocumentDB / MongoDB configuration
resource "aws_docdb_cluster" "glamecommerce_db_cluster" {
  cluster_identifier   = "glamecommerce_cluster"
  engine               = "docdb"
  master_username      = "root"
  master_password      = "Glamecommerce123"
  db_subnet_group_name = aws_db_subnet_group.my_subnet_group.name
  vpc_security_group_ids = [
    aws_security_group.my_sg.id,
  ]
}

resource "aws_docdb_cluster_instance" "glamecommerce_db_instance" {
  identifier   = "glamecommerce_db_instance"
  cluster_identifier = aws_docdb_cluster.example.id
  instance_class = "db.t4g.medium"
  preferred_maintenance_window = "Sun:03:00-Sun:04:00"
  auto_minor_version_upgrade = true
  apply_immediately = true
}

output "docdb_endpoint_url" {
  value = "mongodb://root:Glamecommerce123@${aws_docdb_cluster.glamecommerce_db_instance.endpoint}:27017/ecommerce?tls=true&tlsCAFile=rds-combined-ca-bundle.pem&retryWrites=false"
}

resource "aws_db_subnet_group" "my_subnet_group" {
  name       = "my-subnet-group"
  subnet_ids = [
    aws_subnet.my_subnet_a.id,
    aws_subnet.my_subnet_b.id,
    aws_subnet.my_subnet_c.id,
  ]
}

resource "aws_security_group" "my_sg" {
  name_prefix = "my-sg"
}

resource "aws_security_group_rule" "ingress_to_docdb" {
  type        = "ingress"
  from_port   = 27017
  to_port     = 27017
  protocol    = "tcp"
  cidr_blocks = [
    aws_subnet.my_subnet_a.cidr_block,
    aws_subnet.my_subnet_b.cidr_block,
    aws_subnet.my_subnet_c.cidr_block,
  ]
  security_group_id = aws_security_group.my_sg.id
}

# Define the CodePipeline configuration for the client
resource "aws_codepipeline" "glam_client" {
  name     = "glam-client-codepipeline"
  role_arn = var.client_codepipeline_role_arn

  artifact_store {
    location = var.codepipeline_s3_bucket_name
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name            = "Source"
      category        = "Source"
      owner           = "ThirdParty"
      provider        = "GitHub"
      version         = "2"
      output_artifacts = ["SourceArtifact"]
      configuration = {
        Owner      = var.github_owner
        Repo       = var.github_repo_fe
        Branch     = var.github_branch
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ElasticBeanstalk"
      version         = "1"
      input_artifacts = ["SourceArtifact"]
      configuration = {
        ApplicationName = aws_elastic_beanstalk_application.client_app.name
        EnvironmentName = aws_elastic_beanstalk_environment.client_staging_env.name
      }
    }
  }

  stage {
    name = "Pre-production"

    action {
      name            = "ManualApproval"
      category        = "Approval"
      owner           = "AWS"
      provider        = "Manual"
      version         = "1"
      input_artifacts = []
      configuration = {
        NotificationArn = aws_sns_topic.manual_approval_arn.arn
        CustomData      = "Manual approval needed for pre-production deployment."
      }
    }
  }

  stage {
    name = "Production"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ElasticBeanstalk"
      version         = "1"
      input_artifacts = ["source_artifact"]
      configuration = {
        ApplicationName = aws_elastic_beanstalk_application.server_app.name
        EnvironmentName = aws_elastic_beanstalk_environment.glam_client_production.name
      }
    }
  }
}