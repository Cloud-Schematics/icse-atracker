##############################################################################
# Fail if Atracket COS Bucket Not Found
##############################################################################

locals {
  all_bucket_names = [
    for bucket in var.cos_buckets :
    bucket.shortname
  ]
  atracker_cos_bucket_not_found = (
    var.enable_atracker == true
    ? contains(local.all_bucket_names, var.atracker.collector_bucket_name)
    : true
  )
  CONFIGURATION_FAILURE_atracker_cos_bucket_not_found = regex("true", local.atracker_cos_bucket_not_found)
}

##############################################################################