import json
import redis
import os

def lambda_handler(event, context):
    # Update with your EC2 instance's private IP address and Redis port (default: 6379)
    redis_host = os.getenv("AWS_LIGHTSAIL_REDIS_URL")
    redis_port = 6379  # Default Redis port
    redis_key = "last100earthquakes"  # Key you want to retrieve

    try:
        # Connect to Redis
        r = redis.Redis(host=redis_host, port=redis_port)

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
