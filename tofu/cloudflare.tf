locals {
  access_apps = {
    grafana = {
      name     = "Grafana"
      hostname = "grafana.${local.domain_name}"
    }
  }
}

# Google as an Access login method
resource "cloudflare_zero_trust_access_identity_provider" "google" {
  account_id = local.cloudflare_account_id
  name       = "Google"
  type       = "google"

  config = {
    client_id     = local.google_client_id
    client_secret = local.google_client_secret
  }
}

# Self-hosted Access applications with inline policies
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

# Rate limiting for Home Assistant auth endpoints
resource "cloudflare_ruleset" "ha_rate_limit" {
  zone_id     = local.cloudflare_zone_id
  name        = "Home Assistant auth rate limit"
  description = "Rate limit login attempts to Home Assistant"
  kind        = "zone"
  phase       = "http_ratelimit"

  rules = [{
    description = "Rate limit HA auth endpoints"
    expression  = "(http.host eq \"ha.${local.domain_name}\" and starts_with(http.request.uri.path, \"/auth/\"))"
    action      = "block"
    ratelimit = {
      characteristics     = ["cf.colo.id", "ip.src"]
      requests_per_period = 5
      period              = 10
      mitigation_timeout  = 10
    }
  }]
}
