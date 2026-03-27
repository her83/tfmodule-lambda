import botocore.session
import hvac
import json
import os
import sys
import time

def aws_iam_login_with_retry(client, credentials, role, max_attempts=5, base_delay=2, region='us-east-1', mount_point='aws'):
    for attempt in range(1, max_attempts + 1):
        try:
            # Authenticate to Vault using AWS IAM
            response = client.auth.aws.iam_login(
                access_key=credentials.access_key,
                secret_key=credentials.secret_key,
                session_token=credentials.token,
                role=role,
                use_token=True,
                region='us-east-1',
                mount_point='aws')

            return response
        except Exception as e:
            delay = base_delay * (2 ** (attempt - 1))
            print(f"Login attempt {attempt} failed. Retrying in {delay} seconds. Error: {str(e)}")
 

            # Wait before the next attempt
            time.sleep(delay)
        ## end try
    ## end for
##end def

# Authenticate to vault using the VAULT_TOKEN in environment variable
def authenticate_vault(vault_url):
    # Unset VAULT_TOKEN to avoid interference
    if 'VAULT_TOKEN' in os.environ:
        del os.environ['VAULT_TOKEN']
    ##end if

    # Initialize Vault client
    client = hvac.Client(url=vault_url)

    # Get proper role
    role = 'ee-atlantis-tokengen'
    account = os.environ.get('AWS_RUNNING_ACCOUNT')
    if account == "wdpr-ee-dev":
        role = 'ee-atlantis-tokengen-latest'
    ##end if

    # Fetch AWS credentials using botocore
    session = botocore.session.Session(profile='default')
    credentials = session.get_credentials().get_frozen_credentials()

    max_attempts=5
    base_delay=5

    response = aws_iam_login_with_retry(client, credentials, role, max_attempts, base_delay)

    # Check if authentication was successful
    if not response or not response.get('auth', {}).get('client_token'):
        raise Exception(f"AWS IAM authentication to Vault {vault_url} failed")
    ## end if

    # Set the Vault token for subsequent requests
    client.token = response['auth']['client_token']
    if not client.is_authenticated():
        raise Exception("Authentication failed")
    ## end if

    return client
## end def

# Recursively list/read from vault and return result map
def process_folder(client, base_path, sub_path,  result_map):
    try: 
        current_path = f"{base_path}{sub_path}"
        if current_path.endswith('/'):
            response = client.secrets.kv.v2.list_secrets(mount_point='non_secret', path=f"{current_path}")
            for item in response['data']['keys']:
                process_folder(client,base_path,f"{sub_path}{item}",result_map)
        else:
            read_secret(client, current_path, sub_path, result_map)
    except Exception as e:
        return

# Read the secrets
def read_secret(client, current_path, sub_path, result_map):
    read_response = client.secrets.kv.v2.read_secret_version(mount_point='non_secret', path=f"{current_path}", raise_on_deleted_version=False)
    data = read_response['data']['data']
    if data != None:
        for key, value in data.items():
            separator = "/" if len(sub_path) > 0 else ""
            result_map[f"{sub_path}{separator}{key}"] = str(value)

def main():
    base_path = sys.argv[1]
    vault_url = sys.argv[2]
  
    client = authenticate_vault(vault_url)

    result_map = {}

    if not base_path.endswith("/"):
        try: 
            read_secret(client, base_path, "", result_map)
        except Exception as e:
            process_folder(client,f"{base_path}/","", result_map)        
    else:
        process_folder(client,base_path,"", result_map)

    # Convert result_map to JSON format
    result_json = json.dumps(result_map, indent=2)

    # Print the JSON
    print(result_json)

if __name__ == "__main__":
    main()