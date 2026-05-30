# --------------------------------------------------------------------------
# Cloudflare Zero Trust — Identity Provider + Access Applications + Policies
# --------------------------------------------------------------------------

locals {
  access_apps = {
    grafana = {
      name     = "Grafana"
      hostname = "grafana.${local.domain_name}"
    }
    ha = {
      name     = "Home Assistant"
      hostname = "ha.${local.domain_name}"
    }
  }
}

# --- Google as an Access login method ---

resource "cloudflare_zero_trust_access_identity_provider" "google" {
  account_id = local.cloudflare_account_id
  name       = "Google"
  type       = "google"

  config = {
    client_id     = local.google_client_id
    client_secret = local.google_client_secret
  }
}

# --- Self-hosted Access applications with inline policies ---

resource "cloudflare_zero_trust_access_application" "apps" {
  for_each = local.access_apps

  account_id = local.cloudflare_account_id
  name       = each.value.name
  type       = "self_hosted"
  domain     = each.value.hostname

  session_duration           = "24h"
  auto_redirect_to_identity  = true
  allowed_idps               = [cloudflare_zero_trust_access_identity_provider.google.id]
  http_only_cookie_attribute = true
  same_site_cookie_attribute = "lax"

  policies = [{
    name       = "Allow admin"
    decision   = "allow"
    precedence = 1
    include = [{
      email = {
        email = local.access_admin_email
      }
    }]
  }]
}
