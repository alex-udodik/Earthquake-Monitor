import json
import os
import urllib.request
import boto3

# Upstash REST API (no raw redis-py TCP client) -- avoids depending on a
# Lambda layer for `redis` and matches the pattern already validated for the
# EC2 relay and the web frontend.
UPSTASH_REST_URL = os.environ["UPSTASH_REDIS_REST_URL"]
UPSTASH_REST_TOKEN = os.environ["UPSTASH_REDIS_REST_TOKEN"]


def lambda_handler(event, context):
    redis_key = "last100earthquakes"  # Key you want to retrieve

    try:
        req = urllib.request.Request(
            f"{UPSTASH_REST_URL}/get/{redis_key}",
            headers={"Authorization": f"Bearer {UPSTASH_REST_TOKEN}"},
        )
        with urllib.request.urlopen(req, timeout=5) as resp:
            body = json.loads(resp.read())

        result = body.get("result")
        if result is None:
            print("key is 'None' from Upstash")

        parsed_value = json.loads(result) if result else []

        response = {
            "action": "initData",
            "message": parsed_value
        }

        print("response: " + str(response))

        connectionId = event['requestContext']['connectionId']
        url = ("https://" + event["requestContext"]["domainName"] + "/" + event["requestContext"]["stage"])

        apigatewaymanagementapi = boto3.client(
            'apigatewaymanagementapi',
            endpoint_url=url)

        apigatewaymanagementapi.post_to_connection(
            Data=json.dumps(response),
            ConnectionId=connectionId
        )

    except Exception as e:
        print(e)
    return {}
