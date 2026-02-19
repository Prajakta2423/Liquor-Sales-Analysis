import requests
import os

def lambda_handler(event, context):

    repo  = os.environ["REPO"]
    token = os.environ["TOKEN"]

    print("Triggered by S3 event")
    print("Repo:", repo)

    url = f"https://api.github.com/repos/{repo}/actions/workflows/deploy.yml/dispatches"

    headers = {
        "Authorization": f"Bearer {token}",
        "Accept": "application/vnd.github+json"
    }

    payload = {"ref": "main"}

    response = requests.post(url, headers=headers, json=payload)

    print("STATUS:", response.status_code)
    print("RESPONSE:", response.text)

    return {"statusCode": response.status_code}
