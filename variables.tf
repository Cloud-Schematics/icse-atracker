##############################################################################
# Account Variables
##############################################################################

variable "region" {
  description = "The region to which to deploy the VPC"
  type        = string
}

variable "prefix" {
  description = "The prefix that you would like to prepend to your resources"
  type        = string
}

variable "tags" {
  description = "List of Tags for the resource created"
  type        = list(string)
  default     = null
}

##############################################################################

##############################################################################
# COS Variables
##############################################################################

variable "cos_buckets" {
  description = "List of buckets from ICSE Cloud Service Module"
  type = list(
    object({
      instance_shortname = string # Shortname of COS instance
      instance_id        = string # COS instance ID
      shortname          = string # bucket shortname
      id                 = string # Bucket ID
      name               = string # Bucket composed name
      crn                = string # Bucket CRN
    })
  )
}

##############################################################################

##############################################################################
# Atracker Variables
##############################################################################

variable "enable_atracker" {
  description = "Enable Atracker"
  type        = bool
  default     = true
}

variable "atracker" {
  description = "atracker variables"
  type = object({
    receive_global_events = optional(bool)
    add_route             = optional(bool)
    collector_bucket_name = optional(string)
  })
}

##############################################################################