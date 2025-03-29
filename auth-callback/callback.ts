import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { getCookieValue, setCookie, invalidateCookie } from './lib/cookies';

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

interface State {
    nonce: string;
    redirectUri: string;
}

const decodeState = (event: APIGatewayProxyEvent): State => {
    const cookieState = getCookieValue(event, 'tesla_auth_state');
    const queryState = event.queryStringParameters?.state;

    if (!cookieState || !queryState || cookieState !== queryState) {
        throw new Error(`Invalid state: Cookie: ${cookieState}, Query: ${queryState}`);
    }

    return JSON.parse(atob(cookieState));
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

    try {
        const { redirectUri } = decodeState(event);
        const code = getCode(event);
        const accessToken = await getAccessToken<AccessTokenResponse>(code);

        const tokenCookie = setCookie('tesla_access_token', accessToken.access_token);
        const authFlagCookie = setCookie('is_authenticated', "1", false);
        const invalidateStateCookie = invalidateCookie(event, 'tesla_auth_state');

        return {
            statusCode: 301,
            headers: {
                'Content-Type': 'application/json',
                'Location': redirectUri
            },
            multiValueHeaders: {
                'Set-Cookie': [tokenCookie, authFlagCookie, invalidateStateCookie]
            },
            body: "Redirecting to " + redirectUri
        };
    } catch (e) {
        console.error("Error: ", e);
        return {
            statusCode: 401,
            body: "Unauthorized"
        };
    }
}