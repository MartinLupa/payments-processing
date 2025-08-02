FROM nginx:alpine

# Install apache utils for httpswd
RUN apk add --no-cache apache2-utils 

# Remove default NGINX configuration
RUN rm /etc/nginx/conf.d/default.conf
RUN rm /etc/nginx/nginx.conf

# Copy configuration templates (https://devopsian.net/p/nginx-config-template-with-environment-vars/)
COPY conf.d/payments_processing_gateway.conf.template /etc/nginx/templates/payments_processing_gateway.conf.template
COPY nginx.conf /etc/nginx/nginx.conf

# Copy script to generate htpasswd
COPY scripts/generate-htpasswd.sh /docker-entrypoint.d/10-generate-htpasswd.sh
RUN chmod +x /docker-entrypoint.d/10-generate-htpasswd.sh

# Start NGINX
CMD ["nginx", "-g", "daemon off;"]