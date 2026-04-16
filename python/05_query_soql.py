"""Step 5: SOQL queries using simple-salesforce.

Demonstrates sf.query() (up to 2000 records) and sf.query_all() (full pagination),
plus relationship queries across objects.

Run with:
    uv run python 05_query_soql.py
"""

from auth import get_salesforce_connection


def query_accounts(sf) -> None:
    print("--- Query: Accounts (LIMIT 10) ---")
    result = sf.query("SELECT Id, Name, Phone, Industry FROM Account LIMIT 10")
    print(f"  Records returned: {len(result['records'])} of {result['totalSize']} total")
    for record in result["records"]:
        print(f"  {record['Id']} | {record['Name']} | {record.get('Industry') or 'N/A'}")


def query_contacts_with_account(sf) -> None:
    print("--- Query: Contacts with Account name (relationship query) ---")
    result = sf.query(
        "SELECT Id, FirstName, LastName, Email, Account.Name FROM Contact LIMIT 10"
    )
    print(f"  Records returned: {len(result['records'])}")
    for record in result["records"]:
        account_name = record.get("Account", {}) or {}
        account_name = account_name.get("Name") if account_name else "No Account"
        name = f"{record.get('FirstName') or ''} {record['LastName']}".strip()
        print(f"  {name} | {record.get('Email') or 'N/A'} | Account: {account_name}")


def query_open_cases(sf) -> None:
    print("--- Query: Open Cases ---")
    result = sf.query(
        "SELECT Id, Subject, Status, Priority, Account.Name FROM Case "
        "WHERE Status != 'Closed' LIMIT 10"
    )
    print(f"  Open cases: {len(result['records'])}")
    for record in result["records"]:
        account_name = record.get("Account", {}) or {}
        account_name = account_name.get("Name") if account_name else "No Account"
        print(f"  [{record['Priority']}] {record['Subject']} | {record['Status']} | {account_name}")


def query_all_accounts(sf) -> None:
    print("--- Query All: Accounts (handles pagination automatically) ---")
    # query_all() follows nextRecordsUrl automatically until all records are retrieved.
    # Use this when you expect more than 2,000 records.
    result = sf.query_all("SELECT Id, Name FROM Account")
    print(f"  Total accounts in org: {result['totalSize']}")
    print(f"  Records retrieved: {len(result['records'])}")


def main():
    sf = get_salesforce_connection()

    query_accounts(sf)
    print()
    query_contacts_with_account(sf)
    print()
    query_open_cases(sf)
    print()
    query_all_accounts(sf)

    print("\nDone.")


if __name__ == "__main__":
    main()
