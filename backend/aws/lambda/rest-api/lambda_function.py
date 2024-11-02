import json
import redis

def lambda_handler(event, context):
    # Update with your EC2 instance's private IP address and Redis port (default: 6379)
    redis_host = 'AWS_LIGHTSAIL_REDIS_URL'
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
                'body': json.dumps({'error': 'Key not found'})
            }

        return {
            'statusCode': 200,
            'body': json.dumps({'value': value.decode('utf-8')})  # Decode bytes to string
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
