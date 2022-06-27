##############################################################################
# Activity Tracker is only supported in the following regions, resources
# will only be provisioned where supported
##############################################################################

locals {
  valid_atracker_region = contains(
    ["us-south", "us-east", "eu-de", "eu-gb", "au-syd"],
    var.region
  ) && var.enable_atracker
}

##############################################################################

##############################################################################
# Bucket List to Map
##############################################################################

module "bucket_map" {
  source         = "./list_to_map"
  list           = var.cos_buckets
  key_name_field = "shortname"
}

##############################################################################

##############################################################################
# Create key to allow Atracker to access cos instance where bucket is created
##############################################################################

resource "ibm_resource_key" "atracker_cos_key" {
  count                = local.valid_atracker_region ? 1 : 0
  name                 = "${var.prefix}-atracker-cos-bind-key"
  role                 = "Writer"
  resource_instance_id = module.bucket_map.value[var.atracker.collector_bucket_name].instance_id
  tags                 = var.tags
}

##############################################################################

##############################################################################
# Activity Tracker Target
##############################################################################

resource "ibm_atracker_target" "atracker_target" {
  count = local.valid_atracker_region ? 1 : 0
  cos_endpoint {
    endpoint   = "s3.private.${var.region}.cloud-object-storage.appdomain.cloud"
    target_crn = module.bucket_map.value[var.atracker.collector_bucket_name].instance_id
    bucket     = module.bucket_map.value[var.atracker.collector_bucket_name].name
    api_key    = ibm_resource_key.atracker_cos_key[0].credentials.apikey
  }
  name        = "${var.prefix}-atracker"
  target_type = "cloud_object_storage"
}

##############################################################################

##############################################################################
# Optionally add Atracker Route
##############################################################################

resource "ibm_atracker_route" "atracker_route" {
  count = var.atracker.add_route == true && local.valid_atracker_region ? 1 : 0
  name  = "${var.prefix}-atracker-route"
  rules {
    target_ids = [
      ibm_atracker_target.atracker_target[0].id
    ]
    locations = flatten([
      [var.region],
      lookup(var.atracker, "receive_global_events", null) == null ? [] : ["global"]
    ])
  }
}

##############################################################################