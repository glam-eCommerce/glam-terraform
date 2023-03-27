provider "aws" {
  region = "ap-east-1"
}

resource "aws_vpc" "backup" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "backup-vpc"
  }
}

resource "aws_subnet" "backup_public" {
  vpc_id = aws_vpc.backup.id
  cidr_block = "10.1.1.0/24"
  availability_zone = "ap-east-1a"
}

resource "aws_subnet" "backup_private" {
  vpc_id = aws_vpc.backup.id
  cidr_block = "10.1.2.0/24"
  availability_zone = "ap-east-1a"
}

resource "aws_security_group" "backup_frontend" {
  name_prefix = "backup-frontend"
  vpc_id = aws_vpc.backup.id
}

resource "aws_security_group" "backup_backend" {
  name_prefix = "backup-backend"
  vpc_id = aws_vpc.backup.id
}

module "backup_frontend" {
  source = "terraform-aws-modules/elastic-beanstalk/aws"
  name = "backup-frontend"
  environment_type = "SingleInstance"
  solution_stack_name = "64bit Amazon Linux 2 v5.5.5 running Docker 20.10.7"
  application_name = "glam-shop-client"
  version_label = "latest"
  instance_type = "t3.micro"
  subnet_ids = [aws_subnet.backup_public.id]
  security_group_ids = [aws_security_group.backup_frontend.id]
}

module "backup_backend" {
  source = "terraform-aws-modules/elastic-beanstalk/aws"
  name = "backup-backend"
  environment_type = "SingleInstance"
  solution_stack_name = "64bit Amazon Linux 2 v5.5.5 running Docker 20.10.7"
  application_name = "glam-shop-server"
  version_label = "latest"
  instance_type = "t3.micro"
  subnet_ids = [aws_subnet.backup_private.id]
  security_group_ids = [aws_security_group.backup_backend.id]
}

resource "aws_codepipeline" "backup_frontend" {
  name = "backup-frontend-pipeline"
  role_arn = aws_iam_role.pipeline.arn
  artifact_store {
    type = "S3"
    location = "backup-frontend-artifacts"
  }
  stages {
    name = "Source"
    actions {
      name = "Source"
      category = "Source"
      owner = "ThirdParty"
      provider = "GitHub"
      version = "1"
      output_artifacts = ["source"]
      configuration = {
        Owner = var.github_owner
        Repo = var.github_repo_fe
        Branch = var.github_branch
        OAuthToken = var.github_oauth_token
      }
    }
  }
}

resource "aws_codepipeline" "backup_backend" {
  name = "backup-backend-pipeline"
  role_arn = aws_iam_role.pipeline.arn
  artifact_store {
    type = "S3"
    location = "backup-backend-artifacts"
  }
  stages {
    name = "Source"
    actions {
      name = "Source"
      category = "Source"
      owner = "ThirdParty"
      provider = "GitHub"
      version = "1"
      output_artifacts = ["source"]
      configuration = {
        Owner = var.github_owner
        Repo = var.github_repo_be
        Branch = var.github_branch
        OAuthToken = var.github_oauth_token
      }
    }
  }
}

resource "aws_docdb_cluster" "backup" {
  cluster_identifier = "backup-cluster"
  engine = "docdb"
  master_username = "admin"
  master_password = "mypassword"
  preferred_backup_window = "07:00-09:00"
  backup_retention_period = 7
  vpc_security_group_ids = [aws_security_group.backup_backend.id]
}
