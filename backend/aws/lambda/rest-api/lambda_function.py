import json
import os
import urllib.request

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
            return {
                'statusCode': 404,
                'body': {'error': 'Key not found'}
            }

        parsed_value = json.loads(result)

        return {
            'statusCode': 200,
            'body': parsed_value
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': {'error': str(e)}
        }
