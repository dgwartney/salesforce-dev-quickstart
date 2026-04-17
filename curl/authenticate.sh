#!/usr/bin/env bash
# authenticate.sh — Get an OAuth access token from Salesforce
#
# Usage:
#   source authenticate.sh
#
# After sourcing, the following variables are available in your shell:
#   ACCESS_TOKEN  — Bearer token for API requests
#   INSTANCE_URL  — Your org's base URL (e.g., https://yourorg.my.salesforce.com)
#
# Scripts that need authentication should call:
#   source "$(dirname "$0")/authenticate.sh"

set -euo pipefail

# Load .env from parent directory (repo root) or current directory
ENV_FILE=""
if [ -f "../.env" ]; then
    ENV_FILE="../.env"
elif [ -f ".env" ]; then
    ENV_FILE=".env"
else
    echo "ERROR: .env file not found." >&2
    echo "Copy .env.example to .env and fill in your credentials." >&2
    exit 1
fi

# Export variables from .env (skip comments and blank lines)
set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

# Verify required variables are set
for var in SF_USERNAME SF_PASSWORD SF_SECURITY_TOKEN SF_CONSUMER_KEY SF_CONSUMER_SECRET; do
    if [ -z "${!var:-}" ]; then
        echo "ERROR: $var is not set in $ENV_FILE" >&2
        exit 1
    fi
done

LOGIN_URL="${SF_INSTANCE_URL:-https://login.salesforce.com}"

echo "Authenticating as ${SF_USERNAME}..."

# POST to Salesforce OAuth token endpoint
# password = SF_PASSWORD concatenated directly with SF_SECURITY_TOKEN (no separator)
# --data-urlencode is required for username and password to handle special characters
# (e.g., '+' in email addresses must be encoded as %2B, not treated as a space)
RESPONSE=$(curl -s -X POST "${LOGIN_URL}/services/oauth2/token" \
    -d "grant_type=password" \
    -d "client_id=${SF_CONSUMER_KEY}" \
    -d "client_secret=${SF_CONSUMER_SECRET}" \
    --data-urlencode "username=${SF_USERNAME}" \
    --data-urlencode "password=${SF_PASSWORD}${SF_SECURITY_TOKEN}")

# Check for error in response
if echo "$RESPONSE" | grep -q '"error"'; then
    echo "ERROR: Authentication failed." >&2
    echo "$RESPONSE" | python3 -m json.tool >&2 2>/dev/null || echo "$RESPONSE" >&2
    exit 1
fi

# Extract access token and instance URL using python3 (avoids jq dependency for core auth)
ACCESS_TOKEN=$(echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['access_token'])")
INSTANCE_URL=$(echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['instance_url'])")

export ACCESS_TOKEN
export INSTANCE_URL

echo "Authenticated successfully."
echo "Instance URL: ${INSTANCE_URL}"
echo "Token prefix: ${ACCESS_TOKEN:0:20}..."
