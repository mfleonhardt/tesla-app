import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';

const tokenUrl = "https://fleet-auth.prd.vn.cloud.tesla.com/oauth2/v3/token";
const audience = "https://fleet-api.prd.vn.cloud.tesla.com";

interface AccessTokenResponse {
    access_token: string;
    refresh_token: string;
    id_token: string;
    expires_in: number;
    state: string;
    token_type: string;
}

const getCode = (event: APIGatewayProxyEvent): string => {
    const code = event.queryStringParameters?.code;
    if (!code) {
        throw new Error("No code provided");
    }
    return code;
}

const getAccessToken = async <AccessTokenResponse>(code: string): Promise<AccessTokenResponse> => {
    const clientId = process.env.TESLA_CLIENT_ID;
    const clientSecret = process.env.TESLA_CLIENT_SECRET;
    const redirectUri = process.env.TESLA_REDIRECT_URI;

    if (!clientId || !clientSecret || !redirectUri) {
        throw new Error("Missing environment variables");
    }

    return fetch(tokenUrl, {
        method: "POST",
        headers: {
            "Content-Type": "application/x-www-form-urlencoded",
        },
        body: new URLSearchParams({
            grant_type: "authorization_code",
            client_id: clientId,
            client_secret: clientSecret,
            code: code,
            audience: audience,
            redirect_uri: redirectUri,
        })
    }).then(res => {
        if (!res.ok) {
            throw new Error(`Failed to fetch access token: ${res.statusText}`);
        }
        return res.json() as Promise<AccessTokenResponse>;
    });
}

export const handler = async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {

    console.log("Event: ", event);

    const code = getCode(event);
    const accessToken = await getAccessToken<AccessTokenResponse>(code);

    return {
        statusCode: 200,
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            token: accessToken,
        }),
    }
}