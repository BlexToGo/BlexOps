# run tofu like this:
#   eval $(op signin)
#   export OP_SERVICE_ACCOUNT_TOKEN="$(op read "op://BlexOps/OpenTofu Service Account Auth Token/credential")"
#   export CLOUDFLARE_API_TOKEN="$(op read "op://BlexOps/Cloudflare/opentofu")"
#   tofu apply

provider "google" {
  # Authenticate via Application Default Credentials (gcloud auth application-default login).
  project = "blexops"
}

provider "onepassword" {
  # Authenticates via OP_SERVICE_ACCOUNT_TOKEN env var.
}

provider "cloudflare" {
  # Authenticates via CLOUDFLARE_API_TOKEN env var.
}
