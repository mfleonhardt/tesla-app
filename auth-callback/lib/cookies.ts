import { APIGatewayProxyEventV2 } from 'aws-lambda';
import * as cookie from 'cookie';

const getCookieValue = (event: APIGatewayProxyEventV2, name: string): string | undefined => {
    const cookies = cookie.parse(event.headers.cookie || event.headers.Cookie || '');
    if (!cookies) return undefined;

    return cookies[name];
}

const setCookie = (name: string, value: string, httpOnly: boolean = true, maxAge: number = 3600): string => {
    return cookie.serialize(name, value, {
        path: '/',
        maxAge: maxAge,
        httpOnly: httpOnly,
        secure: true,
        sameSite: 'strict',
        domain: process.env.COOKIE_DOMAIN
    });
}

const invalidateCookie = (name: string): string => {
    return setCookie(name, '', false, -1);
}

export { getCookieValue, setCookie, invalidateCookie };