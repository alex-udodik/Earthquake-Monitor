import redis
import json
import os

r = redis.Redis(
    host='selected-bull-34594.upstash.io',
    port=6379,
    password=os.environ['UPSTASH_REDIS_PASS'],
    ssl=True
)

def lambda_handler(event, context):
    try:
        summary = json.loads(event['body'])

        # Build a flat dictionary of key-value pairs
        kv_pairs = {}
        for country in summary:
            code = country.get("country_code")
            if code:
                key = f"country_summary_{code.lower()}"
                kv_pairs[key] = json.dumps(country)

        # Use MSET to set all key-value pairs at once
        if kv_pairs:
            r.mset(kv_pairs)

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