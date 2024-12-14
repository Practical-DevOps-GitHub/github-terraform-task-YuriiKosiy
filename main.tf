terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "github" {
  token = var.github_token
  owner = "Practical-DevOps-GitHub"
}

data "github_repository" "current_repo" {
  full_name = "Practical-DevOps-GitHub/github-terraform-task-YuriiKosiy"
}

# Add collaborator
resource "github_repository_collaborator" "collaborator" {
  repository = data.github_repository.current_repo.name
  username   = "softservedata"
  permission = "push"
}

resource "github_branch" "develop" {
  repository    = data.github_repository.current_repo.name
  branch        = "develop"
  source_branch = "main"
}

# change Default branch to the "develop"
resource "github_branch_default" "default_branch" {
  repository = data.github_repository.current_repo.name
  branch     = "develop"
  depends_on = [github_branch.develop]
}

# Protect for the "develop"
resource "github_branch_protection" "develop_protection" {
  repository_id  = data.github_repository.current_repo.node_id
  pattern        = "develop"
  enforce_admins = false

  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    required_approving_review_count = 2
  }
}

# Protect for the "main"
resource "github_branch_protection" "main_protection" {
  repository_id  = data.github_repository.current_repo.node_id
  pattern        = "main"
  enforce_admins = false

  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = true
    required_approving_review_count = 1
  }
}

# Codeowners
resource "github_repository_file" "codeowners" {
  repository = data.github_repository.current_repo.name
  file       = ".github/CODEOWNERS"
  content    = "* @softservedata"
}

# Pull Request Template
resource "github_repository_file" "pull_request_template" {
  repository          = data.github_repository.current_repo.name
  file                = ".github/pull_request_template.md"
  content             = <<EOT
## Describe your changes
## Issue ticket number and link
## Checklist before requesting a review
* I have performed a self-review of my code
* If it is a core feature, I have added thorough tests
* Do we need to implement analytics?
* Will this be part of a product update? If yes, please write one phrase about this update
EOT
  overwrite_on_create = true
}

# Deploy Key
resource "github_repository_deploy_key" "deploy_key" {
  repository = data.github_repository.current_repo.name
  title      = "DEPLOY_KEY"
  key        = file("/home/george/.ssh/sprint9.pub")
}

# Personal Access Token (PAT) для GitHub Actions
resource "github_actions_secret" "pat_secret" {
  repository      = data.github_repository.current_repo.name
  secret_name     = "PAT"
  plaintext_value = var.pat_token
}

# Discord Webhook Notification
resource "github_repository_webhook" "discord_webhook" {
  repository = data.github_repository.current_repo.name
  events     = ["pull_request"]

  configuration {
    url          = var.discord_webhook_url
    content_type = "json"
    insecure_ssl = false
  }
}
