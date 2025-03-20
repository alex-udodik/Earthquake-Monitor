import json
import redis
import os
import boto3


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
            print("key is 'None' from redis")
            
            
        # Parse the value as JSON
        parsed_value = json.loads(value.decode('utf-8'))

        response = {
            "action": "initData",
            "message": parsed_value 
            
        }
        
        print("response: " + str(response))
        
        connectionId = event['requestContext']['connectionId']
        url = ("https://" + event["requestContext"]["domainName"] + "/" + event["requestContext"]["stage"])
    
        apigatewaymanagementapi = boto3.client(
            'apigatewaymanagementapi', 
            endpoint_url = url)
        
        apigatewaymanagementapi.post_to_connection(
            Data=json.dumps(response),
            ConnectionId=connectionId
        )
        
    except Exception as e:
        print(e)
    return {}