import json
import redis
import os

def lambda_handler(event, context):
    redis_key = "last100earthquakes"  # Key you want to retrieve

    try:
        # Connect to Redis
        r = redis.Redis(
            host='selected-bull-34594.upstash.io',
            port=6379,
            password=os.getenv("UPSTASH_REDIS_PASS"),
            ssl=True
        )

        # Get the value for the specified key
        value = r.get(redis_key)

        if value is None:
            return {
                'statusCode': 404,
                'body': {'error': 'Key not found'}  # Directly return a dictionary
            }

        # Parse the value as JSON
        parsed_value = json.loads(value.decode('utf-8'))

        return {
            'statusCode': 200,
            'body': parsed_value  # Return parsed JSON directly
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': {'error': str(e)}  # Directly return the error as JSON
        }
