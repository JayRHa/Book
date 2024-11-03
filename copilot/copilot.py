import openai, os, requests

openai.api_type = "azure"
openai.api_version = "2023-08-01-preview"

# Azure OpenAI setup
endpoint_name = "your-openai-endpoint"
openai.api_base = f"https://{endpoint_name}.openai.azure.com/"
openai.api_key = os.getenv("OPENAI_API_KEY")

# Azure AI Search setup
search_endpoint = "https://aisearchintune.search.windows.net"
search_key = os.getenv("SEARCH_KEY")
search_index_name = "intune-index"


def setup_byod(deployment_id: str) -> None:
    class BringYourOwnDataAdapter(requests.adapters.HTTPAdapter):
        def send(self, request, **kwargs):
            request.url = f"{openai.api_base}/openai/deployments/{deployment_id}/extensions/chat/completions?api-version={openai.api_version}"
            return super().send(request, **kwargs)

    session = requests.Session()
    session.mount(
        prefix=f"{openai.api_base}/openai/deployments/{deployment_id}",
        adapter=BringYourOwnDataAdapter(),
    )
    openai.requestssession = session


deployment_id = "gpt-35-turbo"
setup_byod(deployment_id)

message_text = [
    {
        "role": "user",
        "content": "What are the differences between Azure Machine Learning and Azure AI services?",
    }
]

completion = openai.ChatCompletion.create(
    messages=message_text,
    deployment_id=deployment_id,
    dataSources=[
        {
            "type": "AzureCognitiveSearch",
            "parameters": {
                "endpoint": search_endpoint,
                "indexName": search_index_name,
                "semanticConfiguration": "default",
                "queryType": "vectorSemanticHybrid",
                "key": search_key,
                "topNDocuments": 5,
            },
        }
    ],
    temperature=0,
    top_p=1,
    max_tokens=800,
)
print(completion)
