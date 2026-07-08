import json
import os
import urllib.request
import urllib.parse

UPSTASH_REST_URL = os.environ["UPSTASH_REDIS_REST_URL"]
UPSTASH_REST_TOKEN = os.environ["UPSTASH_REDIS_REST_TOKEN"]


def upstash_set(key, value):
    req = urllib.request.Request(
        f"{UPSTASH_REST_URL}/set/{urllib.parse.quote(key)}",
        data=value.encode("utf-8"),
        headers={"Authorization": f"Bearer {UPSTASH_REST_TOKEN}"},
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=5) as resp:
        return json.loads(resp.read())


def lambda_handler(event, context):
    try:
        summary = json.loads(event['body'])

        kv_pairs = {}
        for country in summary:
            code = country.get("country_code")
            if code:
                key = f"country_summary_{code.lower()}"
                kv_pairs[key] = json.dumps(country)

        for key, value in kv_pairs.items():
            upstash_set(key, value)

        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": "Per-country cache updated",
                "count": len(kv_pairs)
            })
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({ "error": str(e) })
        }
