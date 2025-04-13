const { ApiGatewayManagementApiClient, PostToConnectionCommand } = require("@aws-sdk/client-apigatewaymanagementapi");

// The Lambda function handler
exports.handler = async (event) => {
  const domain = event.requestContext.domainName;
  const stage = event.requestContext.stage;
  const connectionId = event.requestContext.connectionId;
  const callbackUrl = `https://${domain}/${stage}`;
  const client = new ApiGatewayManagementApiClient({endpoint:  
  "https://ml07x3skki.execute-api.us-west-2.amazonaws.com/production/"});

  console.log("domain: " + domain);
  console.log("stage: " + stage);
  console.log("connectionId: " + connectionId);
  console.log("callbackurl: " + callbackUrl);
  const requestParams = {
    ConnectionId: connectionId,
    Data: "Hello!",
  };

  const command = new PostToConnectionCommand(requestParams);

  try {
    await client.send(command);
  } catch (error) {
    console.log(error);
  }

  return {
    statusCode: 200,
  };
};