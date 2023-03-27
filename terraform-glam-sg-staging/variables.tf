variable "github_owner" {
  description = "The GitHub owner of the repository"
  type = "string"
  default = "absolutelynoot"
}

variable "github_repo_fe" {
  description = "The GitHub repository name"
  type = "string"
  default = "glam-eCommerce/glam-shop-client"
}

variable "github_repo_be" {
  description = "The GitHub repository name"
  type = "string"
  default = "glam-eCommerce/glam-shop-server"
}

variable "github_branch" {
  description = "The GitHub branch name"
  default     = "main"
}

variable "github_token" {
  description = "The OAuth token for accessing the GitHub repository"
}

variable "datadog_api_key" {
  description = "The API key for datadog dashboard"
  default = ""
}

variable "datadog_app_key" {
    description = "The App key for datadog dashboard"
    default = ""
}