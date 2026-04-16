"""Step 3: Full CRUD operations on Salesforce Contacts.

Creates a temporary Account to link the Contact to, then cleans up both.

Run with:
    uv run python 03_contacts.py
"""

from datetime import datetime
from auth import get_salesforce_connection


def main():
    sf = get_salesforce_connection()
    timestamp = datetime.now().strftime("%Y-%m-%dT%H:%M:%S")

    print("--- Contact CRUD ---")

    # Create a parent Account first (Contact requires an Account to be non-private)
    print("Setup: Creating parent Account...")
    account_result = sf.Account.create({"Name": f"Acme Corp {timestamp}"})
    account_id = account_result["id"]
    print(f"  Parent Account: {account_id}")

    # CREATE
    print("CREATE:")
    result = sf.Contact.create({
        "FirstName": "Jane",
        "LastName": f"Smith {timestamp}",   # LastName is required
        "AccountId": account_id,
        "Email": "jane.smith@acme.example.com",
        "Phone": "(555) 100-0002",
    })
    contact_id = result["id"]
    print(f"  Created Contact: {contact_id}")

    # READ
    print("READ:")
    contact = sf.Contact.get(contact_id)
    print(f"  Contact: {contact['FirstName']} {contact['LastName']}, Email={contact['Email']}")
    print(f"  Linked to Account: {contact['AccountId']}")

    # UPDATE
    print("UPDATE:")
    sf.Contact.update(contact_id, {"Phone": "(555) 100-0099"})
    contact = sf.Contact.get(contact_id)
    print(f"  Updated Contact: Phone is now {contact['Phone']}")

    # DELETE
    print("DELETE:")
    sf.Contact.delete(contact_id)
    print(f"  Deleted Contact: {contact_id}")

    # Cleanup
    print("Cleanup: Deleting parent Account...")
    sf.Account.delete(account_id)
    print(f"  Deleted Account: {account_id}")

    print("Done.")


if __name__ == "__main__":
    main()
