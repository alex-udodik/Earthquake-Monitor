import json
import boto3
import os

dynamodb = boto3.client('dynamodb')

def lambda_handler(event, context):
    message = json.loads(event['body'])['message']
    paginator = dynamodb.get_paginator('scan')
    connectionIds = []

    # Construct the response with the earthquake events
    response = {
        'action': 'earthquake-event',
        'message': message
    }
    
    apigatewaymanagementapi = boto3.client(
        'apigatewaymanagementapi', 
        endpoint_url="https://" + event["requestContext"]["domainName"] + "/" + event["requestContext"]["stage"]
    )

    # Fetch all connections
    for page in paginator.paginate(TableName=os.environ['WEBSOCKET_TABLE']):
        connectionIds.extend(page['Items'])

    # Send message to active clients & remove stale ones
    for connectionId in connectionIds:
        conn_id = connectionId['connectionId']['S']
        try:
            apigatewaymanagementapi.post_to_connection(
                Data=json.dumps(response),
                ConnectionId=conn_id
            )
        except apigatewaymanagementapi.exceptions.GoneException:
            print(f"❌ Removing stale connection: {conn_id}")
            remove_stale_connection(conn_id)  # Remove from DynamoDB
        except Exception as e:
            print(f"⚠️ Error sending to {conn_id}: {str(e)}")

    return {}

def remove_stale_connection(connection_id):
    """ Remove stale WebSocket connections from DynamoDB """
    try:
        dynamodb.delete_item(
            TableName=os.environ['WEBSOCKET_TABLE'],
            Key={'connectionId': {'S': connection_id}}
        )
        print(f"✅ Successfully removed {connection_id} from DynamoDB")
    except Exception as e:
        print(f"⚠️ Failed to remove {connection_id}: {str(e)}")
