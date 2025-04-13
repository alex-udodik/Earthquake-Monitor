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

        for country in summary:
            code = country.get("country_code")
            if code:
                key = f"country_summary_{code.lower()}"
                r.set(key, json.dumps(country))

        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": "Per-country cache updated",
                "count": len(summary)
            })
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({ "error": str(e) })
        }