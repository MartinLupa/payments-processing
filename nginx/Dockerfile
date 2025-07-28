# Use the lightweight Alpine-based NGINX image
FROM nginx:alpine

# Remove default NGINX configuration
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom configuration
COPY conf.d/api_gateway.conf /etc/nginx/conf.d/api_gateway.conf
COPY conf.d/.htpasswd /etc/nginx/conf.d/.htpasswd

# Start NGINX
CMD ["nginx", "-g", "daemon off;"]