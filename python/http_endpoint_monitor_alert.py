import requests
import smtplib
from email.message import EmailMessage
import time

# Configuration
EMAIL_ADDRESS = ""
EMAIL_PASSWORD = ""  # Use your App Password if using Gmail with 2FA
TO_EMAILS = ["<mail1>","<mail2>"]  # List of emails
ENDPOINTS = ["<endpoint1>", "<endpoint2>"]

def send_email(subject, body):
    try:
        with smtplib.SMTP('smtp.gmail.com', 587) as server:
            server.starttls()  
            server.login(EMAIL_ADDRESS, EMAIL_PASSWORD)
            for recipient in TO_EMAILS:
                msg = EmailMessage()
                msg.set_content(body)
                msg['Subject'] = subject
                msg['From'] = EMAIL_ADDRESS
                msg['To'] = recipient
                server.send_message(msg)
                print(f"Email sent successfully to {recipient}!")
    except Exception as e:
        print(f"Failed to send email: {e}")

def check_endpoints():
    for endpoint in ENDPOINTS:
        try:
            response = requests.get(endpoint)
            if response.status_code != 200:
                print(f"{endpoint} is down. Status Code: {response.status_code}")
                send_email("Endpoint Down Alert", f"{endpoint} is down. Status Code: {response.status_code}")
            else:
                print(f"{endpoint} is reachable.")
        except requests.exceptions.RequestException as e:
            print(f"{endpoint} is down. Error: {e}")
            send_email("Endpoint Down Alert", f"{endpoint} is down. Error: {e}")

if __name__ == "__main__":
    while True:
        check_endpoints()
        time.sleep(600)
