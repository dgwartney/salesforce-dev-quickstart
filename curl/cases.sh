#!/usr/bin/env bash
# cases.sh — Full CRUD operations on Salesforce Cases via curl
#
# Creates a temporary Account and Contact to link the Case to, then cleans up all three.
#
# Usage:
#   bash cases.sh
#
# Requires: curl, jq, python3

set -euo pipefail

# shellcheck disable=SC1091
source "$(dirname "$0")/authenticate.sh"

API_VERSION="${SF_API_VERSION:-v62.0}"
DATA_URL="${INSTANCE_URL}/services/data/${API_VERSION}/sobjects"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo ""
echo "--- Case CRUD ---"

# Setup: create a parent Account and Contact
echo ""
echo "Setup: Creating parent Account and Contact..."
ACCOUNT_RESPONSE=$(curl -s -X POST "${DATA_URL}/Account/" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{\"Name\": \"Acme Corp ${TIMESTAMP}\"}")
ACCOUNT_ID=$(echo "$ACCOUNT_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])")

CONTACT_RESPONSE=$(curl -s -X POST "${DATA_URL}/Contact/" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{\"LastName\": \"Smith ${TIMESTAMP}\", \"AccountId\": \"${ACCOUNT_ID}\"}")
CONTACT_ID=$(echo "$CONTACT_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])")

echo "  Account: ${ACCOUNT_ID}"
echo "  Contact: ${CONTACT_ID}"

# ── CREATE ──────────────────────────────────────────────────────────────────
echo ""
echo "CREATE: POST /sobjects/Case/"
CREATE_RESPONSE=$(curl -s -X POST "${DATA_URL}/Case/" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{
        \"Subject\": \"Login button not working on mobile ${TIMESTAMP}\",
        \"Status\": \"New\",
        \"Priority\": \"High\",
        \"Origin\": \"Web\",
        \"AccountId\": \"${ACCOUNT_ID}\",
        \"ContactId\": \"${CONTACT_ID}\",
        \"Description\": \"Customer reports the login button does not respond on iOS 17.\"
    }")
echo "$CREATE_RESPONSE" | jq .
CASE_ID=$(echo "$CREATE_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])")
echo "  Case ID: ${CASE_ID}"

# ── READ ─────────────────────────────────────────────────────────────────────
echo ""
echo "READ: GET /sobjects/Case/${CASE_ID}"
curl -s "${DATA_URL}/Case/${CASE_ID}" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    | jq '{Id, Subject, Status, Priority, AccountId, ContactId}'

# ── UPDATE ───────────────────────────────────────────────────────────────────
echo ""
echo "UPDATE: PATCH /sobjects/Case/${CASE_ID}"
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X PATCH "${DATA_URL}/Case/${CASE_ID}" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    -d '{"Status": "Working"}')
echo "  HTTP Status: ${HTTP_STATUS}"
curl -s "${DATA_URL}/Case/${CASE_ID}" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    | jq '{Status}'

# ── DELETE ───────────────────────────────────────────────────────────────────
echo ""
echo "DELETE: DELETE /sobjects/Case/${CASE_ID}"
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE "${DATA_URL}/Case/${CASE_ID}" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}")
echo "  HTTP Status: ${HTTP_STATUS}"
echo "  Case ${CASE_ID} deleted."

# Cleanup
echo ""
echo "Cleanup: Deleting Contact and Account..."
curl -s -o /dev/null -X DELETE "${DATA_URL}/Contact/${CONTACT_ID}" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}"
curl -s -o /dev/null -X DELETE "${DATA_URL}/Account/${ACCOUNT_ID}" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}"
echo "  Cleanup complete."

echo ""
echo "Done."
