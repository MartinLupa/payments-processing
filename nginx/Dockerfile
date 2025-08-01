# Use the lightweight Alpine-based NGINX image
FROM nginx:alpine

# Install apache2-utils for htpasswd
RUN apk add --no-cache apache2-utils

# Remove default NGINX configuration
RUN rm /etc/nginx/conf.d/default.conf

# Copy configuration template (https://devopsian.net/p/nginx-config-template-with-environment-vars/)
COPY conf.d/api_gateway.conf.template /etc/nginx/templates/api_gateway.conf.template

# Copy script to generate htpasswd
COPY scripts/generate-htpasswd.sh /docker-entrypoint.d/10-generate-htpasswd.sh
RUN chmod +x /docker-entrypoint.d/10-generate-htpasswd.sh

# Copy custom configuration
# COPY conf.d/.htpasswd /etc/nginx/conf.d/.htpasswd

# Start NGINX
CMD ["nginx", "-g", "daemon off;"]