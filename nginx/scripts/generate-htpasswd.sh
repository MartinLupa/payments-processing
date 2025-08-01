#!/bin/ash

# Generate .htpasswd file from environment variables
if [ -z "$API_GATEWAY_USER" ] || [ -z "$API_GATEWAY_PASSWORD" ]; then
    echo "Error: API_GATEWAY_USER and API_GATEWAY_PASSWORD must be set"
    exit 1
fi

# Create .htpasswd file
htpasswd -cb /etc/nginx/conf.d/.htpasswd "$API_GATEWAY_USER" "$API_GATEWAY_PASSWORD"

echo "Generated .htpasswd file for user: $API_GATEWAY_USER"
