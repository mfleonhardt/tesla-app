import { nanoid } from "nanoid";
import Cookies from "universal-cookie";

const encodeState = (redirectUri: string): string => {
    const state = JSON.stringify({
        nonce: nanoid(16),
        redirectUri: redirectUri
    });
    return btoa(state);
}

const userAuthorizationUrl = (redirectUri: string) => {
    const state = encodeState(redirectUri);
    const cookies = new Cookies();
    cookies.set("tesla_auth_state", state, {
        path: "/",
        maxAge: 60 * 10,
        secure: true,
        domain: import.meta.env.VITE_COOKIE_DOMAIN
    });

    const url = new URL("https://auth.tesla.com/oauth2/v3/authorize");
    url.searchParams.set("response_type", "code");
    url.searchParams.set("client_id", import.meta.env.VITE_CLIENT_ID);
    url.searchParams.set("redirect_uri", import.meta.env.VITE_CALLBACK_URL);
    url.searchParams.set("scope", "openid offline_access user_data vehicle_device_data vehicle_cmds vehicle_charging_cmds");
    url.searchParams.set("state", state);

    return url.toString();
}

export {
    userAuthorizationUrl
}