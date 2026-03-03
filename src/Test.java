from elasticsearch import Elasticsearch, helpers
import json
from datetime import datetime

# ===== CONFIG =====
ELASTIC_HOST = "https://your-elastic-host:9200"
USERNAME = "your_username"
PASSWORD = "your_password"
INDEX_NAME = "your-index-name"
OUTPUT_FILE = "kibana_export.json"
SCROLL_TIMEOUT = "2m"
BATCH_SIZE = 1000


def create_client():
    return Elasticsearch(
        ELASTIC_HOST,
        basic_auth=(USERNAME, PASSWORD),
        verify_certs=True,
        request_timeout=60
    )


def fetch_all_documents(es: Elasticsearch, index: str):
    """
    Uses Scroll API for large data extraction.
    """
    query = {
        "query": {
            "match_all": {}
        }
    }

    response = es.search(
        index=index,
        body=query,
        scroll=SCROLL_TIMEOUT,
        size=BATCH_SIZE
    )

    scroll_id = response["_scroll_id"]
    hits = response["hits"]["hits"]

    while hits:
        for doc in hits:
            yield doc["_source"]

        response = es.scroll(
            scroll_id=scroll_id,
            scroll=SCROLL_TIMEOUT
        )
        scroll_id = response["_scroll_id"]
        hits = response["hits"]["hits"]

    es.clear_scroll(scroll_id=scroll_id)


def save_to_file(data_generator, filename: str):
    with open(filename, "w") as f:
        for doc in data_generator:
            f.write(json.dumps(doc) + "\n")


if __name__ == "__main__":
    print("Connecting to Elasticsearch...")
    es_client = create_client()

    print(f"Downloading data from index: {INDEX_NAME}")
    data_gen = fetch_all_documents(es_client, INDEX_NAME)

    save_to_file(data_gen, OUTPUT_FILE)

    print(f"Data successfully saved to {OUTPUT_FILE}")
