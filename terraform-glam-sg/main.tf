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
    Name = "terraform-vpc-glam-sg"
  }
}

# Creating subnets
resource "aws_subnet" "public_a" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-southeast-1a"
  tags = {
    Name = "terraform-public-subnet-1a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-southeast-1b"
  tags = {
    Name = "terraform-public-subnet-1b"
  }
}

resource "aws_subnet" "public_c" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-southeast-1c"
  tags = {
    Name = "terraform-public-subnet-1c"
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

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_c" {
  subnet_id      = aws_subnet.public_c.id
  route_table_id = aws_route_table.public.id
}

resource "aws_iam_role" "beanstalk_instance_role" {
  name = "beanstalk-instance-role-terraform"

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
  name = "beanstalk-instance-profile-terraform"
  role = aws_iam_role.beanstalk_instance_role.name
}

# ELASTIC IP ADDRESSES
# resource "aws_eip" "eip_client_staging" {
#   vpc = true
# }

# resource "aws_eip_association" "eip_association_client_staging" {
#   instance_id   = aws_elastic_beanstalk_environment.client_staging_env.id
#   allocation_id = aws_eip.eip_client_staging.id
# }

# resource "aws_eip" "eip_server_staging" {
#   vpc = true
# }

# resource "aws_eip_association" "eip_association_server_staging" {
#   instance_id   = aws_elastic_beanstalk_environment.server_staging_env.id
#   allocation_id = aws_eip.eip_server_staging.id
# }

# Define the Elastic Beanstalk CLIENT application 
resource "aws_elastic_beanstalk_application" "client_app" {
  name = "glam-docker-client-eb-terraform"
}

# Define the Elastic Beanstalk for the CLIENT staging environment
resource "aws_elastic_beanstalk_environment" "client_staging_env" {
  name                = "glam-client-staging-terraform"
  application         = aws_elastic_beanstalk_application.client_app.name
  solution_stack_name = "64bit Amazon Linux 2 v3.5.5 running Docker"
  
  # Configure the Elastic Beanstalk environment with the necessary properties for the client code

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "NODE_ENV"
    value     = "production"
  }

  # keypair
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = "glam-admin-keypair"
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
    value     = "${join(",", [aws_subnet.public_a.id], [aws_subnet.public_b.id], [aws_subnet.public_c.id])}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "REACT_APP_API_URL"
    value     = ""
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
  
}

# Define the Elastic Beanstalk for the CLIENT production environment
resource "aws_elastic_beanstalk_environment" "client_production_env" {
  name                = "glam-client-production-terraform"
  application         = aws_elastic_beanstalk_application.client_app.name
  solution_stack_name = "64bit Amazon Linux 2 v3.5.5 running Docker"
  
  # Configure the Elastic Beanstalk environment with the necessary properties for the client code

  # Set up a VPC for the Elastic Beanstalk environment
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = aws_vpc.my_vpc.id
  }

    # keypair
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = "glam-admin-keypair"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.beanstalk_instance_profile.name
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = "${join(",", [aws_subnet.public_a.id], [aws_subnet.public_b.id], [aws_subnet.public_c.id])}"
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
    value     = ""
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
  
}

# Define the Elastic Beanstalk SERVER application 
resource "aws_elastic_beanstalk_application" "server_app" {
  name = "glam-docker-server-eb-terraform"
}

# Define the Elastic Beanstalk for the SERVER staging environment
resource "aws_elastic_beanstalk_environment" "server_staging_env" {
  name                = "glam-server-staging-terraform"
  application         = aws_elastic_beanstalk_application.server_app.name
  solution_stack_name = "64bit Amazon Linux 2 v3.5.5 running Docker"

  # Configure the Elastic Beanstalk environment with the necessary properties for the server code
  
  # Set up a VPC for the Elastic Beanstalk environment
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = aws_vpc.my_vpc.id
  }

    # keypair
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = "glam-admin-keypair"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.beanstalk_instance_profile.name
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = "${join(",", [aws_subnet.public_a.id], [aws_subnet.public_b.id], [aws_subnet.public_c.id])}"
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
    value     = "mongodb://root:Glamecommerce123@${aws_docdb_cluster.glamecommerce_db_cluster.endpoint}:27017/ecommerce?tls=true&tlsCAFile=rds-combined-ca-bundle.pem&retryWrites=false"
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
  
}

# Define the Elastic Beanstalk for the SERVER production environment
resource "aws_elastic_beanstalk_environment" "server_production_env" {
  name                = "glam-server-production-terraform"
  application         = aws_elastic_beanstalk_application.server_app.name
  solution_stack_name = "64bit Amazon Linux 2 v3.5.5 running Docker"
  
  # Configure the Elastic Beanstalk environment with the necessary properties for the server code
  # Set up a VPC for the Elastic Beanstalk environment
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = aws_vpc.my_vpc.id
  }
  
    # keypair
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = "glam-admin-keypair"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.beanstalk_instance_profile.name
  }

  setting {
  namespace = "aws:ec2:vpc"
  name      = "Subnets"
  value     = "${join(",", [aws_subnet.public_a.id], [aws_subnet.public_b.id], [aws_subnet.public_c.id])}"
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
    value     = "mongodb://root:Glamecommerce123@${aws_docdb_cluster.glamecommerce_db_cluster.endpoint}:27017/ecommerce?tls=true&tlsCAFile=rds-combined-ca-bundle.pem&retryWrites=false"
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
  
}

# Define DocumentDB / MongoDB configuration
resource "aws_docdb_cluster" "glamecommerce_db_cluster" {
  cluster_identifier   = "glamecommerce-cluster-terraform"
  engine               = "docdb"
  master_username      = "root"
  master_password      = "Glamecommerce123"
  db_subnet_group_name = aws_db_subnet_group.new_subnet_group.name
  vpc_security_group_ids = [
    aws_security_group.docdb_sg.id
  ]
}

resource "aws_docdb_cluster_instance" "glamecommerce_db_instance" {
  identifier   = "glamecommerce-docdb-instance-terraform"
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
  cidr_block = "10.0.5.0/24"
  availability_zone = "ap-southeast-1a"
  tags = {
    "Name" = "private-subnet-1a-terraform-docdb"
  }
}
resource "aws_subnet" "my_subnet_b" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.6.0/24"
  availability_zone = "ap-southeast-1b"
  tags = {
    "Name" = "private-subnet-1b-terraform-docdb"
  }
}

resource "aws_db_subnet_group" "new_subnet_group" {
  name       = "subnet-group-terraform"
  subnet_ids = [
    aws_subnet.my_subnet_a.id,
    aws_subnet.my_subnet_b.id
  ]
}

resource "aws_security_group" "docdb_sg" {
  name_prefix = "docdb-sg-terraform"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}