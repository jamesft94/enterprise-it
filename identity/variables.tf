variable "domain" {
  description = "Domain used for new user principal names."
  type        = string
}

variable "usage_location" {
  description = "Two-letter country code. Required before a licence can be assigned."
  type        = string
  default     = "NO"
}

variable "departments" {
  description = "Departments that get their own dynamic group. Must match the department column in users.csv."
  type        = list(string)
  default     = ["Engineering", "Operations", "Support", "Sales", "Finance"]
}
