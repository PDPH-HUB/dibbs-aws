import msal
import requests
import yaml
from pathlib import Path

# Environment selector
ENVIRONMENT = "prod"

def load_config():
    script_dir = Path(__file__).parent.parent
    config_path = script_dir / 'configs' / 'migrate-db_config.yml'
    with open(config_path, 'r') as file:
        config = yaml.safe_load(file)
    return config[ENVIRONMENT]

# Load configuration
config = load_config()

# Entra config
CLIENT_ID = config['client_id']
CLIENT_SECRET = config['client_secret']
TENANT_ID = config['tenant_id']
AUTHORITY = f"https://login.microsoftonline.com/{TENANT_ID}"
DIBBS_SCOPE = f"{CLIENT_ID}/.default"

# migrate-db config
DIBBS_URL = config['base_url']
MIGRATION_SECRET = config['migration_secret']
INIT_ADMIN_EMAIL = config['init_admin_email']

def get_bearer_token():
    app = msal.ConfidentialClientApplication(CLIENT_ID, client_credential=CLIENT_SECRET, authority=AUTHORITY)
    result = app.acquire_token_for_client(scopes=[DIBBS_SCOPE])
    
    if result is not None and "access_token" in result:
        return result["access_token"]
    else:
        print(f"Error: {result.get('error', 'Unknown error')}") # type: ignore
        print(f"Description: {result.get('error_description', 'No description')}") # type: ignore
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