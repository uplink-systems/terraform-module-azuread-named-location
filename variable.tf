####################################################################################################
#   variable.tf                                                                                    #
####################################################################################################

variable "named_location" {
  description = <<-EOF
    'var.named_location' is the main variable for azuread_named_location resource settings.
    - (Required) named location's display name
    - (Optional) country-based named location parameters
    - (Optional) ip-based named location parameters
  EOF
  type        = object({
    display_name  = string
    country       = optional(object({
      enabled                               = optional(bool, true)
      countries_and_regions                 = optional(list(string), [])
      country_lookup_method                 = optional(string)
      include_unknown_countries_and_regions = optional(bool, false)
    }), { enabled = false })
    ip            = optional(object({
      enabled                               = optional(bool, true)
      ip_ranges                             = optional(list(string), [])
      trusted                               = optional(bool, false)
    }), { enabled = false})
  })
  validation {
    condition     = var.named_location.country.enabled || var.named_location.ip.enabled
    error_message = <<-EOF
      No block 'country' or 'ip' is configured in 'named_location' variable.
      Must be at least one of either 'country' or 'ip'.
    EOF
  }
  validation {
    condition     = !(var.named_location.country.enabled) || !(var.named_location.ip.enabled)
    error_message = <<-EOF
      Both blocks 'country' and 'ip' are configured in 'named_location' variable.
      Must be only one of either 'country' or 'ip'.
    EOF
  }
  validation {
    condition     = var.named_location.country.country_lookup_method == null ? true : contains(["clientIpAddress", "authenticatorAppGps"], var.named_location.country.country_lookup_method)
    error_message = <<-EOF
      Value for 'var.named_location.country.country_lookup_method' is invalid: ${var.named_location.country.country_lookup_method == null ? 0 : var.named_location.country.country_lookup_method}
      Must be one of:
        "clientIpAddress", "authenticatorAppGps" or null
    EOF
  }
}
