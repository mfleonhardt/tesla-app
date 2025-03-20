const userAuthorizationUrl = () => {
    console.log("Redirect URI: ", import.meta.env.VITE_CALLBACK_URL);

    const url = new URL("https://auth.tesla.com/oauth2/v3/authorize");
    url.searchParams.set("response_type", "code");
    url.searchParams.set("client_id", import.meta.env.VITE_CLIENT_ID);
    url.searchParams.set("redirect_uri", import.meta.env.VITE_CALLBACK_URL);
    url.searchParams.set("scope", "openid offline_access user_data vehicle_device_data vehicle_cmds vehicle_charging_cmds");
    url.searchParams.set("state", "1234567890");

    return url.toString();
}

export {
    userAuthorizationUrl
}