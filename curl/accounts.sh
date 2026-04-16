#!/usr/bin/env bash
# accounts.sh — Full CRUD operations on Salesforce Accounts via curl
#
# Usage:
#   bash accounts.sh
#
# Requires: curl, jq, python3 (for authentication)

set -euo pipefail

# Authenticate and export ACCESS_TOKEN + INSTANCE_URL
# shellcheck disable=SC1091
source "$(dirname "$0")/authenticate.sh"

API_VERSION="${SF_API_VERSION:-v62.0}"
BASE_URL="${INSTANCE_URL}/services/data/${API_VERSION}/sobjects/Account"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo ""
echo "--- Account CRUD ---"

# ── CREATE ──────────────────────────────────────────────────────────────────
echo ""
echo "CREATE: POST /sobjects/Account/"
CREATE_RESPONSE=$(curl -s -X POST "${BASE_URL}/" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{
        \"Name\": \"Test Corp ${TIMESTAMP}\",
        \"Phone\": \"(555) 999-0001\",
        \"Industry\": \"Technology\"
    }")

echo "$CREATE_RESPONSE" | jq .
# Expected: {"id":"001...","success":true,"created":true}
# HTTP 201 Created

ACCOUNT_ID=$(echo "$CREATE_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])")
echo "  Account ID: ${ACCOUNT_ID}"

# ── READ ─────────────────────────────────────────────────────────────────────
echo ""
echo "READ: GET /sobjects/Account/${ACCOUNT_ID}"
curl -s "${BASE_URL}/${ACCOUNT_ID}" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    | jq '{Id, Name, Phone, Industry}'
# HTTP 200 OK

# ── UPDATE ───────────────────────────────────────────────────────────────────
echo ""
echo "UPDATE: PATCH /sobjects/Account/${ACCOUNT_ID}"
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X PATCH "${BASE_URL}/${ACCOUNT_ID}" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    -d '{"Phone": "(555) 999-0002"}')
echo "  HTTP Status: ${HTTP_STATUS}"
# HTTP 204 No Content (success, no response body)

# Verify the update
echo "  Verify: GET /sobjects/Account/${ACCOUNT_ID}"
curl -s "${BASE_URL}/${ACCOUNT_ID}" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    | jq '{Id, Name, Phone}'

# ── DELETE ───────────────────────────────────────────────────────────────────
echo ""
echo "DELETE: DELETE /sobjects/Account/${ACCOUNT_ID}"
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE "${BASE_URL}/${ACCOUNT_ID}" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}")
echo "  HTTP Status: ${HTTP_STATUS}"
# HTTP 204 No Content (success, no response body)
echo "  Account ${ACCOUNT_ID} deleted."

echo ""
echo "Done."
