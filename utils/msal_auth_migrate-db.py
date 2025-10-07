import msal
import requests

# Entra config
CLIENT_ID = ""
CLIENT_SECRET = ""
TENANT_ID = ""
AUTHORITY = f"https://login.microsoftonline.com/{TENANT_ID}"
DIBBS_SCOPE = f"{CLIENT_ID}/.default"

# migrate-db config
DIBBS_URL = "https://pdphdibbs.phila.gov"
MIGRATION_SECRET = ""
INIT_ADMIN_EMAIL = "christopher.stevens@phila.gov"

def get_bearer_token():
    app = msal.ConfidentialClientApplication(CLIENT_ID, client_credential=CLIENT_SECRET, authority=AUTHORITY)
    result = app.acquire_token_for_client(scopes=[DIBBS_SCOPE])
    
    if "access_token" in result:
        return result["access_token"]
    else:
        print(f"Error: {result.get('error', 'Unknown error')}")
        print(f"Description: {result.get('error_description', 'No description')}")
        print(f"Full result: {result}")
        return None

def migrate_db(token):
    url = f"{DIBBS_URL}/ecr-viewer/api/migrate-db"
    headers = {
        'Authorization': f'Bearer {token}'
    }
    
    files = {
        'migration_secret': (None, MIGRATION_SECRET),
        'init_admin_email': (None, INIT_ADMIN_EMAIL)
    }
    
    print(f"Request URL: {url}")
    response = requests.post(url, headers=headers, files=files)
    print(f"Status: {response.status_code}, Response: {response.text}")
        
    return response

if __name__ == "__main__":
    print("Attempting to get bearer token...")
    access_token = get_bearer_token()
    if access_token:
        print(f"Success! Token acquired")
        
        print("\nCalling migrate-db API...")
        api_response = migrate_db(access_token)
        
    else:
        print("Failed to get token.")