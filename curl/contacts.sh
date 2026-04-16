#!/usr/bin/env bash
# contacts.sh — Full CRUD operations on Salesforce Contacts via curl
#
# Creates a temporary Account to link the Contact to, then cleans up both.
#
# Usage:
#   bash contacts.sh
#
# Requires: curl, jq, python3

set -euo pipefail

# shellcheck disable=SC1091
source "$(dirname "$0")/authenticate.sh"

API_VERSION="${SF_API_VERSION:-v62.0}"
DATA_URL="${INSTANCE_URL}/services/data/${API_VERSION}/sobjects"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo ""
echo "--- Contact CRUD ---"

# Setup: create a parent Account (Contact without AccountId is "private")
echo ""
echo "Setup: Creating parent Account..."
ACCOUNT_RESPONSE=$(curl -s -X POST "${DATA_URL}/Account/" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{\"Name\": \"Acme Corp ${TIMESTAMP}\"}")
ACCOUNT_ID=$(echo "$ACCOUNT_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])")
echo "  Parent Account: ${ACCOUNT_ID}"

# ── CREATE ──────────────────────────────────────────────────────────────────
echo ""
echo "CREATE: POST /sobjects/Contact/"
CREATE_RESPONSE=$(curl -s -X POST "${DATA_URL}/Contact/" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{
        \"FirstName\": \"Jane\",
        \"LastName\": \"Smith ${TIMESTAMP}\",
        \"AccountId\": \"${ACCOUNT_ID}\",
        \"Email\": \"jane.smith@acme.example.com\",
        \"Phone\": \"(555) 100-0002\"
    }")
echo "$CREATE_RESPONSE" | jq .
CONTACT_ID=$(echo "$CREATE_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])")
echo "  Contact ID: ${CONTACT_ID}"

# ── READ ─────────────────────────────────────────────────────────────────────
echo ""
echo "READ: GET /sobjects/Contact/${CONTACT_ID}"
curl -s "${DATA_URL}/Contact/${CONTACT_ID}" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    | jq '{Id, FirstName, LastName, Email, Phone, AccountId}'

# ── UPDATE ───────────────────────────────────────────────────────────────────
echo ""
echo "UPDATE: PATCH /sobjects/Contact/${CONTACT_ID}"
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X PATCH "${DATA_URL}/Contact/${CONTACT_ID}" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    -d '{"Phone": "(555) 100-0099"}')
echo "  HTTP Status: ${HTTP_STATUS}"
curl -s "${DATA_URL}/Contact/${CONTACT_ID}" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    | jq '{Phone}'

# ── DELETE ───────────────────────────────────────────────────────────────────
echo ""
echo "DELETE: DELETE /sobjects/Contact/${CONTACT_ID}"
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE "${DATA_URL}/Contact/${CONTACT_ID}" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}")
echo "  HTTP Status: ${HTTP_STATUS}"
echo "  Contact ${CONTACT_ID} deleted."

# Cleanup
echo ""
echo "Cleanup: Deleting parent Account..."
curl -s -o /dev/null -X DELETE "${DATA_URL}/Account/${ACCOUNT_ID}" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}"
echo "  Account ${ACCOUNT_ID} deleted."

echo ""
echo "Done."
