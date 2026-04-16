"""Step 1: Verify authentication with Salesforce.

Run with:
    uv run python 01_authenticate.py
"""

from auth import get_salesforce_connection


def main():
    print("Connecting to Salesforce...")
    sf = get_salesforce_connection()

    # sf.sf_instance contains the org's instance URL (e.g., yourorg.my.salesforce.com)
    # sf.sf_org_id contains the 18-character org ID
    print(f"Connected to Salesforce org: {sf.sf_org_id}")
    print(f"Instance URL: https://{sf.sf_instance}")
    print("Authentication successful.")


if __name__ == "__main__":
    main()
