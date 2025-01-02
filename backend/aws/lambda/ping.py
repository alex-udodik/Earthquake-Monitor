import json
import boto3
import os

def lambda_handler(event, context):
    
    # Initialize the API Gateway management client inside the handler
    apigatewaymanagementapi = boto3.client('apigatewaymanagementapi', 
        endpoint_url="https://" + event["requestContext"]["domainName"] + "/" + event["requestContext"]["stage"])

    # Parse the incoming message
    message = json.loads(event['body'])
    if message['action'] == 'ping':
        # Respond with a pong message to keep the connection alive
        response = {
            'action': 'pong',
            'message': 'pong'
        }
        apigatewaymanagementapi.post_to_connection(
            Data=json.dumps(response),
            ConnectionId=event['requestContext']['connectionId']
        )
   
    return {
        'statusCode': 200,
        'body': json.dumps('Message processed')
    }
