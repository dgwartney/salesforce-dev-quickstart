"""Shared Salesforce connection helper.

Usage:
    from auth import get_salesforce_connection
    sf = get_salesforce_connection()
"""

import os
from dotenv import load_dotenv
from simple_salesforce import Salesforce


def get_salesforce_connection() -> Salesforce:
    """Load credentials from .env and return an authenticated Salesforce instance.

    Note: simple-salesforce handles appending the security token to the password
    internally. Do NOT manually append the token to SF_PASSWORD here.
    """
    load_dotenv()

    required = [
        "SF_USERNAME",
        "SF_PASSWORD",
        "SF_SECURITY_TOKEN",
        "SF_CONSUMER_KEY",
        "SF_CONSUMER_SECRET",
    ]
    missing = [var for var in required if not os.environ.get(var)]
    if missing:
        raise EnvironmentError(
            f"Missing required environment variables: {', '.join(missing)}\n"
            "Copy .env.example to .env and fill in all values."
        )

    return Salesforce(
        username=os.environ["SF_USERNAME"],
        password=os.environ["SF_PASSWORD"],
        security_token=os.environ["SF_SECURITY_TOKEN"],
        consumer_key=os.environ["SF_CONSUMER_KEY"],
        consumer_secret=os.environ["SF_CONSUMER_SECRET"],
    )
