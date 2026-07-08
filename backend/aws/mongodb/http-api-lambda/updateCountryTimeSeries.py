import json
import os
import urllib.request
import urllib.parse

UPSTASH_REST_URL = os.environ["UPSTASH_REDIS_REST_URL"]
UPSTASH_REST_TOKEN = os.environ["UPSTASH_REDIS_REST_TOKEN"]


def upstash_get(key):
    req = urllib.request.Request(
        f"{UPSTASH_REST_URL}/get/{urllib.parse.quote(key)}",
        headers={"Authorization": f"Bearer {UPSTASH_REST_TOKEN}"},
    )
    with urllib.request.urlopen(req, timeout=5) as resp:
        body = json.loads(resp.read())
    return body.get("result")


def upstash_set(key, value):
    req = urllib.request.Request(
        f"{UPSTASH_REST_URL}/set/{urllib.parse.quote(key)}",
        data=value.encode("utf-8"),
        headers={"Authorization": f"Bearer {UPSTASH_REST_TOKEN}"},
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=5) as resp:
        return json.loads(resp.read())


def handler(event, context):
    try:
        print("🚀 Lambda triggered")
        print(f"🔍 Event received: {event}")

        parsed = json.loads(event['body'])
        docs = parsed if isinstance(parsed, list) else [parsed]

        print(f"📦 Parsed {len(docs)} document(s) from body")

        count = 0
        for doc in docs:
            country_code = doc.get("country_code", "unknown").lower()
            interval = doc.get("interval", "unknown").lower()
            key = f"{country_code}_{interval}"

            print(f"➡️  Processing doc for key: {key}")

            existing_raw = upstash_get(key)
            if existing_raw:
                print(f"📡 Found existing key: {key}")
                try:
                    existing_array = json.loads(existing_raw)
                except Exception as decode_error:
                    print(f"⚠️ Failed to decode existing value: {decode_error}")
                    existing_array = []
            else:
                print(f"🆕 No existing key. Initializing: {key}")
                existing_array = []

            existing_array.append(doc)
            existing_array.sort(key=lambda d: d.get("timestamp", ""), reverse=True)

            upstash_set(key, json.dumps(existing_array))
            print(f"✅ Updated Redis key: {key} (Total items: {len(existing_array)})")
            count += 1

        print(f"🎯 Done updating {count} key(s)")

        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": "Redis cache updated with country_interval keys",
                "count": count
            })
        }

    except Exception as e:
        print(f"❌ Exception occurred: {str(e)}")
        return {
            "statusCode": 500,
            "body": json.dumps({ "error": str(e) })
        }
