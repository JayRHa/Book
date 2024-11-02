import requests
from azure.identity import InteractiveBrowserCredential

credential = InteractiveBrowserCredential()
token = credential.get_token("https://graph.microsoft.com/.default")


def call_graph(access_token: str, url: str, body, method: str = "GET"):
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json",
    }
    if method == "GET":
        response = requests.get(
            url,
            headers=headers,
        )
    else:
        response = requests.post(
            url,
            headers=headers,
            json=body,
        )
    response.raise_for_status()
    return response.json()


url = "https://graph.microsoft.com/beta/$batch"
body = {
    "requests": [
        {
            "id": "getDeviceComplianceStateSummary",
            "method": "GET",
            "url": "/deviceManagement/deviceCompliancePolicyDeviceStateSummary",
            "headers": {"x-ms-command-name": "fetchDeviceComplianceStateSummaryBatch"},
        },
        {
            "id": "fetchSubscriptionState",
            "method": "GET",
            "url": "/deviceManagement/subscriptionState",
            "headers": {"x-ms-command-name": "fetchSubscriptionStateBatch"},
        },
        {
            "id": "getFailedAppCount",
            "method": "POST",
            "url": "/deviceManagement/reports/getFailedMobileAppsSummaryReport",
            "body": {"filter": ""},
            "headers": {
                "Content-Type": "application/json",
                "x-ms-command-name": "fetchFailedAppCountBatch",
            },
        },
        {
            "id": "getDeviceConfigPolicySummary",
            "method": "POST",
            "url": "/deviceManagement/reports/getDeviceConfigurationPolicyStatusSummary",
            "body": {
                "filter": "(PolicyBaseTypeName eq 'DeviceManagementConfigurationPolicy') or (PolicyBaseTypeName eq 'Microsoft.Management.Services.Api.DeviceConfiguration') or (PolicyBaseTypeName eq 'Microsoft.Management.Services.Api.DeviceManagementIntent')"
            },
            "headers": {
                "Content-Type": "application/json",
                "x-ms-command-name": "fetchDeviceConfigPolicySummary",
            },
        },
    ]
}
response = call_graph(token.token, url, body, "POST")
print(response)
