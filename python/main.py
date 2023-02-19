#!/usr/bin/env python3
from azure.identity import DefaultAzureCredential
from azure.mgmt.compute import ComputeManagementClient

SUBSCRIPTION_ID="YOUR_SUBSCRIPTION_ID"

azure_credential = DefaultAzureCredential()

import os
import requests
# printing environment variables
endpoint = os.getenv('IDENTITY_ENDPOINT')+"?resource=https://management.azure.com/"
identityHeader = os.getenv('IDENTITY_HEADER')
payload={}
headers = {
'X-IDENTITY-HEADER' : identityHeader,
'Metadata' : True
}
response = requests.get(endpoint, headers)
print(response.text)