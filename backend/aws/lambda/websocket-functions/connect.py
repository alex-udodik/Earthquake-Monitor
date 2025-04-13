import boto3
import os

dynamodb = boto3.client('dynamodb')

def lambda_handler(event, context):
    connectionId = event['requestContext']['connectionId']

    try:
        # Ensure duplicate connections are removed
        dynamodb.delete_item(
            TableName=os.environ['WEBSOCKET_TABLE'],
            Key={'connectionId': {'S': connectionId}}
        )

        # Register the new connection
        dynamodb.put_item(
            TableName=os.environ['WEBSOCKET_TABLE'],
            Item={'connectionId': {'S': connectionId}}
        )

        print(f"✅ WebSocket client connected: {connectionId}")
    except Exception as e:
        print(f"⚠️ Error connecting client {connectionId}: {str(e)}")

    return {}