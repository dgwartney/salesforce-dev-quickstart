"""Step 2: Full CRUD operations on Salesforce Accounts.

Run with:
    uv run python 02_accounts.py
"""

from datetime import datetime
from auth import get_salesforce_connection


def create_account(sf, timestamp: str) -> str:
    result = sf.Account.create({
        "Name": f"Test Corp {timestamp}",
        "Phone": "(555) 999-0001",
        "Industry": "Technology",
    })
    account_id = result["id"]
    print(f"  Created Account: {account_id}")
    return account_id


def read_account(sf, account_id: str) -> None:
    account = sf.Account.get(account_id)
    print(f"  Read Account: Name={account['Name']}, Phone={account['Phone']}, Industry={account['Industry']}")


def update_account(sf, account_id: str) -> None:
    sf.Account.update(account_id, {"Phone": "(555) 999-0002"})
    # Verify the update
    account = sf.Account.get(account_id)
    print(f"  Updated Account: Phone is now {account['Phone']}")


def delete_account(sf, account_id: str) -> None:
    sf.Account.delete(account_id)
    print(f"  Deleted Account: {account_id}")


def main():
    sf = get_salesforce_connection()
    timestamp = datetime.now().strftime("%Y-%m-%dT%H:%M:%S")

    print("--- Account CRUD ---")

    print("CREATE:")
    account_id = create_account(sf, timestamp)

    print("READ:")
    read_account(sf, account_id)

    print("UPDATE:")
    update_account(sf, account_id)

    print("DELETE:")
    delete_account(sf, account_id)

    print("Done.")


if __name__ == "__main__":
    main()
