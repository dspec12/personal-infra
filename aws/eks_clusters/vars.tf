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

variable vpc_id {
  type        = string
  default     = ""
  description = "VPC to build the cluster in"
}