
variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to resources"
}

variable "config" {
  type = object({
    aws_region_main   = string
    aws_region_backup = string
    force_destroy     = bool
  })
  description = "Configuration map for s3 bucket"
}

variable "source_bucket" {
  type        = string 
  description = "name of the source bucket"
  validation{
    condition     = length(var.source_bucket) > 0
    error_message = "source_bucket cannot be empty"
  }
}

variable "destination_bucket" {
  type        = string 
  description = "bucket for replicated data" 
}