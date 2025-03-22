import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';

export const handler = async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
    console.log("Event: ", event);
    let responseMessage = 'Hello, world!';

    if (event.queryStringParameters && event.queryStringParameters.name) {
        responseMessage = `Hello, ${event.queryStringParameters.name}!`;
    }

    return {
        statusCode: 200,
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            message: responseMessage,
        }),
    }
}