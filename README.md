# IBM Cloud Solution Engineering Activity Tracker Module

This module creates an Activity Tracker instance and optionally allows users to create an Activity Tracker Route.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Input Variables](#input-variables)
    - [Architecture Level Variables](#architecture-level-variables)
    - [Cloud Object Storage Variables](#cloud-object-storage-variables)
    - [Activity Tracker Variables](#activity-tracker-variables)
3. [Resources](#resources)


---

## Prerequisites

This module assumes that the following infrastructer has been created:
- Cloud Object Storage Instances
- Object Storage Buckets

---

## Input Variables

Full descriptions of input variables for this module can be found in [variables.tf](./variables.tf).

---

### Architecture Level Variables

The following variables are required to be passed in from your architecture to create atracker resources

Name   | Description                                                 | Type
------ | ----------------------------------------------------------- | ------------
region | The region to which to deploy the VPC                       | string
prefix | The prefix that you would like to prepend to your resources | string
tags   | List of Tags for the resource created                       | list(string)
enable_atracker | Enable Activity Tracker | bool

---

### Cloud Object Storage Variables

This module expects a list of `cos_buckets`.

This value is a direct refernce to the outputs from either of the following modules:
- [ICSE Cloud Object Storage Module](https://github.com/Cloud-Schematics/cos-module)
- [ICSE Cloud Services Module](https://github.com/Cloud-Schematics/icse-cloud-services)

```terraform
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
```

---

### Activity Tracker Variables

The following is used to set up your Activity Tracker target and route. *(Note: These values are marked as optional to ensure no input is needed when `var.enable_atracker` is false)*

```terraform
variable "atracker" {
  description = "atracker variables"
  type = object({
    receive_global_events = optional(bool)   # Allow atracker to recieve globale events
    add_route             = optional(bool)   # Add a route to the instance
    collector_bucket_name = optional(string) # Shortname of the collector bucket where logs will be stored
  })
}
```

---

## Resources

Resources will only be provisioned by this module if:
- `var.enable_atracker` is true
- `var.region` is one of the following: `["us-south", "us-east", "eu-de", "eu-gb", "au-syd"]`

### Object Storage Resource Key

A resource key to allow the Activity Tracker instance to write to the collector bucket is created for the Object Storage instance.

### Activity Tracker Target

An activity tracker target is created based on the `var.atracker.collector_bucket_name` value.

### Activity Tracker Route

An activity tracker route can optionall by created by setting the `var.atracker.add_route` value to `true`.

---

## Example Usage

```terraform
module "activity_tracker" {
  source = "github.com/Cloud-Schematics/icse-atracker"
  region          = var.region
  prefix          = var.prefix
  tags            = var.tags
  enable_atracker = var.enable_atracker
  atracker        = var.atracker
  cos_buckets     = module.services.cos_buckets
}
```