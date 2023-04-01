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

# Declaring the VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "terraform-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "terraform-public-subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_iam_role" "beanstalk_instance_role" {
  name = "beanstalk-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "beanstalk_instance_profile" {
  name = "beanstalk-instance-profile"
  role = aws_iam_role.beanstalk_instance_role.name
}

# Define the Elastic Beanstalk CLIENT application 
resource "aws_elastic_beanstalk_application" "client_app" {
  name = "glam-docker-client-eb"
}

# Define the Elastic Beanstalk for the CLIENT staging environment
resource "aws_elastic_beanstalk_environment" "client_staging_env" {
  name                = "glam-docker-client-eb-env-staging"
  application         = aws_elastic_beanstalk_application.client_app.name
  solution_stack_name = "64bit Amazon Linux 2 v3.5.5 running Docker"
  
  # Configure the Elastic Beanstalk environment with the necessary properties for the client code

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "NODE_ENV"
    value     = "production"
  }

  # Set up a VPC for the Elastic Beanstalk environment
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = aws_vpc.my_vpc.id
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.beanstalk_instance_profile.name
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = "${join(",", [aws_subnet.my_subnet_a.id], [aws_subnet.my_subnet_b.id])}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "REACT_APP_API_URL"
    value     = "${aws_elastic_beanstalk_environment.server_staging_env.endpoint_url}"
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
  solution_stack_name = "64bit Amazon Linux 2 v3.5.5 running Docker"
  
  # Configure the Elastic Beanstalk environment with the necessary properties for the client code

  # Set up a VPC for the Elastic Beanstalk environment
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = aws_vpc.my_vpc.id
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.beanstalk_instance_profile.name
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = "${join(",", [aws_subnet.my_subnet_a.id], [aws_subnet.my_subnet_b.id])}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "NODE_ENV"
    value     = "production"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "REACT_APP_API_URL"
    # NEEDS TO BE CHANGED!!!
    value     = "${aws_elastic_beanstalk_environment.server_production_env.endpoint_url}"
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

# Define the Elastic Beanstalk SERVER application 
resource "aws_elastic_beanstalk_application" "server_app" {
  name = "glam-docker-server-eb"
}

# Define the Elastic Beanstalk for the SERVER staging environment
resource "aws_elastic_beanstalk_environment" "server_staging_env" {
  name                = "glam-docker-server-eb-env-staging"
  application         = aws_elastic_beanstalk_application.server_app.name
  solution_stack_name = "64bit Amazon Linux 2 v3.5.5 running Docker"

  # Configure the Elastic Beanstalk environment with the necessary properties for the server code
  
  # Set up a VPC for the Elastic Beanstalk environment
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = aws_vpc.my_vpc.id
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.beanstalk_instance_profile.name
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = "${join(",", [aws_subnet.my_subnet_a.id], [aws_subnet.my_subnet_b.id])}"
  }

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
    value     = "${aws_docdb_cluster_instance.glamecommerce_db_instance.endpoint}"
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

# Define the Elastic Beanstalk for the SERVER production environment
resource "aws_elastic_beanstalk_environment" "server_production_env" {
  name                = "glam-docker-server-eb-env-production"
  application         = aws_elastic_beanstalk_application.server_app.name
  solution_stack_name = "64bit Amazon Linux 2 v3.5.5 running Docker"
  
  # Configure the Elastic Beanstalk environment with the necessary properties for the server code
  # Set up a VPC for the Elastic Beanstalk environment
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = aws_vpc.my_vpc.id
  }

    setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.beanstalk_instance_profile.name
  }

  setting {
  namespace = "aws:ec2:vpc"
  name      = "Subnets"
  value     = "${join(",", [aws_subnet.my_subnet_a.id], [aws_subnet.my_subnet_b.id])}"
  }

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
    value     = "${aws_docdb_cluster_instance.glamecommerce_db_instance.endpoint}"
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
  cluster_identifier   = "glamecommerce-cluster"
  engine               = "docdb"
  master_username      = "root"
  master_password      = "Glamecommerce123"
  db_subnet_group_name = aws_db_subnet_group.my_subnet_group.name
  vpc_security_group_ids = [
    aws_security_group.docdb_sg.id
  ]
}

resource "aws_docdb_cluster_instance" "glamecommerce_db_instance" {
  identifier   = "glamecommerce-docdb-instance"
  cluster_identifier = aws_docdb_cluster.glamecommerce_db_cluster.id
  instance_class = "db.t4g.medium"
  preferred_maintenance_window = "Sun:03:00-Sun:04:00"
  auto_minor_version_upgrade = true
  apply_immediately = true
}

output "docdb_endpoint_url" {
  value = "mongodb://root:Glamecommerce123@${aws_docdb_cluster_instance.glamecommerce_db_instance.endpoint}:27017/ecommerce?tls=true&tlsCAFile=rds-combined-ca-bundle.pem&retryWrites=false"
}

# Creating 2 private subnets for DocumentDB for high availability
resource "aws_subnet" "my_subnet_a" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-southeast-1a"
}

resource "aws_subnet" "my_subnet_b" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-southeast-1b"
}

resource "aws_db_subnet_group" "my_subnet_group" {
  name       = "my-subnet-group"
  subnet_ids = [
    aws_subnet.my_subnet_a.id,
    aws_subnet.my_subnet_b.id
  ]
}

resource "aws_security_group" "docdb_sg" {
  name_prefix = "docdb-sg"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
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
      provider        = "GitHubConnection"
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
        NotificationArn = var.sns_topic_arn_client
        CustomData      = "Please check if pre-production environment passed UAT and proceed to deploy to production."
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
      input_artifacts = ["SourceArtifact"]
      configuration = {
        ApplicationName = aws_elastic_beanstalk_application.client_app.name
        EnvironmentName = aws_elastic_beanstalk_environment.client_production_env.name
      }
    }
  }
}

# Define the SNS configuration for the client
# resource "aws_sns_topic" "manual_approval_arn_client" {
#   name = "sns-manual-approval-client-pre-prod"
#   arn = "arn:aws:sns:ap-southeast-1:557048361311:sns-manual-approval-client-pre-prod"
# }

# Define the CodePipeline configuration for the server
resource "aws_codepipeline" "glam_server" {
  name     = "glam-server-codepipeline"
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
      provider        = "GitHubConnection"
      version         = "2"
      output_artifacts = ["SourceArtifact"]
      configuration = {
        Owner      = var.github_owner
        Repo       = var.github_repo_be
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
        ApplicationName = aws_elastic_beanstalk_application.server_app.name
        EnvironmentName = aws_elastic_beanstalk_environment.server_staging_env.name
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
        NotificationArn = var.sns_topic_arn_server
        CustomData      = "Please check if pre-production environment passed UAT and proceed to deploy to production."
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
      input_artifacts = ["SourceArtifact"]
      configuration = {
        ApplicationName = aws_elastic_beanstalk_application.server_app.name
        EnvironmentName = aws_elastic_beanstalk_environment.server_production_env.name
      }
    }
  }
}

# Define the SNS configuration for the server
# resource "aws_sns_topic" "manual_approval_arn_server" {
#   name = "sns-manual-approval-server-pre-prod"
#   arn = "arn:aws:sns:ap-southeast-1:557048361311:sns-manual-approval-server-pre-prod"
# }