data "onepassword_vault" "blexops" {
  name = "BlexOps"
}

data "onepassword_item" "cloudflare" {
  vault = data.onepassword_vault.blexops.uuid
  title = "Cloudflare"
}

data "onepassword_item" "server" {
  vault = data.onepassword_vault.blexops.uuid
  title = "Server"
}

# Manually created item holding the Google OAuth client ID and secret.
data "onepassword_item" "google_oauth" {
  vault = data.onepassword_vault.blexops.uuid
  title = "Cloudflare Access Google OAuth"
}

locals {
  # Flatten all section fields into a simple label -> value map.
  _cf_fields = merge([
    for s in data.onepassword_item.cloudflare.section :
    { for f in s.field : f.label => f.value }
  ]...)

  _server_fields = merge([
    for s in data.onepassword_item.server.section :
    { for f in s.field : f.label => f.value }
  ]...)

  _google_oauth_fields = merge([
    for s in data.onepassword_item.google_oauth.section :
    { for f in s.field : f.label => f.value }
  ]...)

  cloudflare_account_id = lookup(local._cf_fields, "account id", "")
  access_admin_email    = lookup(local._cf_fields, "admin email", "")
  domain_name           = lookup(local._server_fields, "domain name", "")
  google_client_id      = lookup(local._google_oauth_fields, "client id", "")
  google_client_secret  = lookup(local._google_oauth_fields, "client secret", "")
}

# Write Cloudflare Access AUD tags to 1Password to read them in the cloudflare-tunnel Ansible role
resource "onepassword_item" "access_auds" {
  vault    = data.onepassword_vault.blexops.uuid
  title    = "Cloudflare Access AUDs"
  category = "secure_note"

  note_value = "Managed by OpenTofu. Do not edit manually."

  section {
    label = "auds"

    field {
      label = "grafana aud"
      type  = "STRING"
      value = cloudflare_zero_trust_access_application.apps["grafana"].aud
    }

    field {
      label = "ha aud"
      type  = "STRING"
      value = cloudflare_zero_trust_access_application.apps["ha"].aud
    }
  }
}
