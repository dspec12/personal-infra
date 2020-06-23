variable region {
  type        = string
  default     = "us-east-1"
  description = "AWS Region"
}

variable env_stage {
  type        = string
  default     = ""
  description = "Example: dev, stg, prod"
}

variable azs {
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
  description = "List of availability zones"
}
