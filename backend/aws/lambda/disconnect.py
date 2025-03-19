import boto3
import os

dynamodb = boto3.client('dynamodb')

def lambda_handler(event, context):
    connectionId = event['requestContext']['connectionId']

    try:
        dynamodb.delete_item(
            TableName=os.environ['WEBSOCKET_TABLE'],
            Key={'connectionId': {'S': connectionId}}
        )
        print(f"✅ Disconnected client removed: {connectionId}")
    except Exception as e:
        print(f"⚠️ Error removing client {connectionId}: {str(e)}")

    return {}
