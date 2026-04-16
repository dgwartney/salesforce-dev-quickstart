"""Step 4: Full CRUD operations on Salesforce Cases.

Creates a temporary Account and Contact to link the Case to, then cleans up all three.

Run with:
    uv run python 04_cases.py
"""

from datetime import datetime
from auth import get_salesforce_connection


def main():
    sf = get_salesforce_connection()
    timestamp = datetime.now().strftime("%Y-%m-%dT%H:%M:%S")

    print("--- Case CRUD ---")

    # Create parent Account and Contact
    print("Setup: Creating parent Account and Contact...")
    account_result = sf.Account.create({"Name": f"Acme Corp {timestamp}"})
    account_id = account_result["id"]

    contact_result = sf.Contact.create({
        "LastName": f"Smith {timestamp}",
        "AccountId": account_id,
    })
    contact_id = contact_result["id"]
    print(f"  Account: {account_id}")
    print(f"  Contact: {contact_id}")

    # CREATE
    print("CREATE:")
    result = sf.Case.create({
        "Subject": f"Login button not working on mobile {timestamp}",   # Subject is required
        "Status": "New",
        "Priority": "High",
        "Origin": "Web",
        "AccountId": account_id,
        "ContactId": contact_id,
        "Description": "Customer reports the login button on the mobile app does not respond when tapped on iOS 17.",
    })
    case_id = result["id"]
    print(f"  Created Case: {case_id}")

    # READ
    print("READ:")
    case = sf.Case.get(case_id)
    print(f"  Case: Subject={case['Subject']}")
    print(f"  Status={case['Status']}, Priority={case['Priority']}")

    # UPDATE
    print("UPDATE:")
    sf.Case.update(case_id, {"Status": "Working"})
    case = sf.Case.get(case_id)
    print(f"  Updated Case: Status is now {case['Status']}")

    # DELETE
    print("DELETE:")
    sf.Case.delete(case_id)
    print(f"  Deleted Case: {case_id}")

    # Cleanup
    print("Cleanup: Deleting Contact and Account...")
    sf.Contact.delete(contact_id)
    sf.Account.delete(account_id)
    print("  Cleanup complete.")

    print("Done.")


if __name__ == "__main__":
    main()
