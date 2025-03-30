#!/usr/bin/env bash

working_dir=$(pwd)

cd terraform
tesla_app_subdomain="dev-$(cd "$working_dir/terraform" && terraform output -raw tesla_app_subdomain)" || {
  echo "❌ failed to read tesla_app_subdomain"
  exit 1
}
tesla_callback_subdomain="dev-$(cd "$working_dir/terraform" && terraform output -raw tesla_callback_subdomain)" || {
  echo "❌ failed to read tesla_callback_subdomain"
  exit 1
}
cd "$working_dir"

echo "This script will:"
echo
echo "  🗑️  Remove any existing certificates in the 'certs' directory"
echo "  🔐 Create new certificates for domains:"
echo "    🌐 $tesla_app_subdomain"
echo "    🌐 $tesla_callback_subdomain"
echo ""
read -p "Do you want to continue? (y/n): " confirm

if [[ $confirm != "y" && $confirm != "Y" ]]; then
    echo "Operation cancelled."
    exit 0
fi

echo "Proceeding with certificate creation..."

mkdir -p "$working_dir/certs"
rm -f "$working_dir/certs/*"

app_key_path="$working_dir/certs/app-key.pem"
app_cert_path="$working_dir/certs/app-cert.pem"
api_key_path="$working_dir/certs/api-key.pem"
api_cert_path="$working_dir/certs/api-cert.pem"

mkcert -key-file "$app_key_path" -cert-file "$app_cert_path" "$tesla_app_subdomain"
mkcert -key-file "$api_key_path" -cert-file "$api_cert_path" "$tesla_callback_subdomain"

rm -f app/.env.local
echo "VITE_DEV_HOST=${tesla_app_subdomain}" >> app/.env.local
echo "VITE_KEY_PATH=${app_key_path}" >> app/.env.local
echo "VITE_CERT_PATH=${app_cert_path}" >> app/.env.local

if ! grep -q "$tesla_app_subdomain" /etc/hosts; then
  echo "⚠️  Reminder: add '$tesla_app_subdomain' and '$tesla_callback_subdomain' to /etc/hosts"
fi
