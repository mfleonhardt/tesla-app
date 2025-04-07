#!/usr/bin/env bash

if [ ! -f .env ]; then
    echo "Creating .env file from .env.dist"

    cp .env.dist .env

    echo "Enter values then run this script again."
    exit
fi

echo "Creating application secrets"
source .env

cat > app/.env <<EOF
VITE_CLIENT_ID=${TESLA_CLIENT_ID}
VITE_CALLBACK_URL=${AUTH_REDIRECT_URI}
EOF

cat > auth-callback/.env <<EOF
TESLA_CLIENT_ID=${TESLA_CLIENT_ID}
TESLA_CLIENT_SECRET=${TESLA_CLIENT_SECRET}
TESLA_REDIRECT_URI=${AUTH_REDIRECT_URI}
EOF

echo "Done!"
