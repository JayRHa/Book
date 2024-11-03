import os
import requests

# Set up environment variables
azure_search_secret = os.getenv("AZURE_SEARCH_KEY")
azure_search_endpoint = "https://your-search-resource.search.windows.net"
file_share_connection_string = os.getenv("FILE_SHARE_CONNECTION_STRING")

# Define the data source
data_source_name = "ds-secret-intune-info"
datasource_url = f"{azure_search_endpoint}/datasources/{data_source_name}?api-version=2024-05-01-Preview"

body = {
    "name": data_source_name,
    "description": "It is very secret",
    "type": "azurefile",
    "credentials": {"connectionString": file_share_connection_string},
    "container": {"name": "intune", "query": "secret"},
    "dataDeletionDetectionPolicy": {
        "@odata.type": "#Microsoft.Azure.Search.SoftDeleteColumnDeletionDetectionPolicy",
        "softDeleteColumnName": "IsDeleted",
        "softDeleteMarkerValue": "true",
    },
}

# Send the request to create the data source
response = requests.put(
    datasource_url,
    json=body,
    timeout=1000,
    headers={"api-key": azure_search_secret, "Content-Type": "application/json"},
)

# Output the response
print(response.json())
