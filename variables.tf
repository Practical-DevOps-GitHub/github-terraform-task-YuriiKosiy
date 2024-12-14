variable "github_token" {
  type        = string
  description = "GitHub Token для Terraform"
  default     = "" 
}

variable "pat_token" {
  type        = string
  description = "PAT Token для GitHub Actions"
  default     = "" 
}

variable "discord_webhook_url" {
  description = "Discord webhook URL for notifications"
  type        = string
  sensitive   = true
  default     = ""
}