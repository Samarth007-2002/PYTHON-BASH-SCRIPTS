import boto3
import re

def fetch_all_secrets():
    secrets_client = boto3.client('secretsmanager')
    secrets_list = []

    # Paginate through all secrets
    paginator = secrets_client.get_paginator('list_secrets')
    for page in paginator.paginate():
        for secret in page['SecretList']:
            secrets_list.append(secret)

    return secrets_list

def scan_for_smtp_in_key(secret_key):
    smtp_keywords = [
        'SMTP_HOST', 'SMTP_USERNAME', 'SMTP_PASSWORD', 'SMTP_PORT'
    ]

    for keyword in smtp_keywords:
        if re.search(keyword, secret_key, re.IGNORECASE):
            return True
    return False

def main():
    secrets_client = boto3.client('secretsmanager')

    try:
        secrets = fetch_all_secrets()

        for secret in secrets:
            secret_name = secret['Name']

            try:
                secret_value_response = secrets_client.get_secret_value(SecretId=secret_name)
                secret_value = secret_value_response.get('SecretString', '')

                if scan_for_smtp_in_key(secret_value):
                    print(f"SMTP-related secret found in value of: {secret_name}")
            except Exception as fetch_error:
                print(f"Error fetching value for {secret_name}: {fetch_error}")

    except Exception as e:
        print(f"Error fetching secrets: {e}")

if __name__ == "__main__":
    main()
