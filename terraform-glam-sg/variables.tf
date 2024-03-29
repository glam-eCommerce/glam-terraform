variable "default_region" {
  description = "The default AWS region to use"
  type = string
  default = "ap-southeast-1"
}

variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type = string
}

variable "github_owner" {
  description = "The GitHub owner of the repository"
  type = string
  default = "absolutelynoot"
}

variable "github_repo_fe" {
  description = "The GitHub repository name"
  type = string
  default = "glam-eCommerce/glam-shop-client"
}

variable "github_repo_be" {
  description = "The GitHub repository name"
  type = string
  default = "glam-eCommerce/glam-shop-server"
}

variable "github_branch" {
  description = "The GitHub branch name"
  default     = "main"
}

# variable "github_token" {
#   description = "The OAuth token for accessing the GitHub repository"
# }

variable "datadog_api_key" {
  description = "The API key for datadog dashboard"
  default = ""
}

variable "datadog_app_key" {
    description = "The App key for datadog dashboard"
    default = ""
}

variable "client_codepipeline_role_arn" {
  default = "arn:aws:iam::557048361311:role/service-role/AWSCodePipelineServiceRole-ap-southeast-1-glam-eCommerce"
}

variable "codepipeline_s3_bucket_name" {
  default = "codepipeline-ap-southeast-1-814300243622"
}

variable "server_codepipeline_role_arn" {
  default = "arn:aws:iam::557048361311:role/service-role/AWSCodePipelineServiceRole-ap-southeast-1-glam-server-codepipel"
}

variable "sns_topic_arn_client" {
  description = "ARN of the client SNS topic for manual approval notifications"
  type        = string
}

variable "sns_topic_arn_server" {
  description = "ARN of the server SNS topic for manual approval notifications"
  type        = string
}
