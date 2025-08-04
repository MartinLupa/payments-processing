# Payments Processing API

A lightweight payments processing microservice built with Ruby/Cuba, featuring asynchronous payment processing, caching, and API gateway functionality.

## App Architecture

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Nginx     │───▶│   Cuba API  │───▶│ PostgreSQL  │
│ API Gateway │    │   Server    │    │  Database   │
└─────────────┘    └─────────────┘    └─────────────┘
                           │
                           ▼
                   ┌─────────────┐    ┌─────────────┐
                   │   Sidekiq   │───▶│    Redis    │
                   │   Worker    │    │   Cache     │
                   └─────────────┘    └─────────────┘
```

## Telemetry Architecture
```
┌─────────────────────┐    ┌───────────────────┐    ┌───────────────────┐
│     Ruby App        │───▶│   OTLP Collector  │───▶│  Visualization UI │
│ (with OTLP Exporter)│    │ (e.g., Jaeger,    │    │ (e.g., Jaeger UI, │
└─────────────────────┘    │   Zipkin, or      │    │   Grafana Tempo)  │
                           │   OpenTelemetry)  │    └───────────────────┘
                           └───────────────────┘
```

### Components

- **Cuba API**: Lightweight web framework handling payment endpoints
- **Nginx**: API gateway with rate limiting and basic authentication
- **PostgreSQL**: Primary database for payment records
- **Redis**: Caching layer and Sidekiq job queue
- **Sidekiq**: Background job processing for payment transactions


## Quick Start

### Prerequisites
- Docker & Docker Compose
- Ruby 3.x (for local development)

### Running with Docker

1. **Start all services:**
   ```bash
   docker-compose up -d
   ```

2. **Set environment variable for the API:**
   ```bash
   export DB_URL="postgres://user:password@localhost:5432/payments"
   ```

3. **Install dependencies and start the API:**
   ```bash
   bundle install
   bundle exec rackup -p 9292
   ```

4. **Start the background worker:**
   ```bash
   bundle exec sidekiq -C ./config/sidekiq.yml -r ./workers/payment_processor_worker.rb
   ```
5. **Steps 3 and 4 can be run together through Foreman**
    ```bash
   foreman start
    ```

## API Endpoints

- `GET /health` - Health check
- `GET /payments` - List all payments
- `POST /payments` - Create new payment
- `GET /payments/:transaction_id` - Get payment by transaction ID
- `PATCH /payments/:transaction_id` - Update payment status

## Example Usage

```bash
# Create a payment
curl -X POST http://localhost/api/v1/payments \
  -H "Content-Type: application/json" \
  -d '{"order_id": "ORD-123", "amount": 99.99, "card_token": "tok_123"}'
```

### Check payment status
```bash
curl http://localhost/api/v1/payments/{transaction_id}
```

## TODO

### 🔴 Critical Issues
- **Mock payment gateway** - always returns success, needs real integration
- **Dummy SSL certificates** - replace with real certificates for production

### 🟡 Security Concerns
- **Basic auth credentials** implement proper credentials handling
- **No input validation** on payment amounts or card tokens

## Learnings from this project
- `Ruby ecosystem`: Puma, Cuba, Rack, Gemfiles, etc.
- `Background job processing`: Sidekiq workers.
- `Docker bind mounts vs copying config files into Dockerfile` (trying to come up with the best developer experience): when doing changes on the nginx config files on my host machine, I had to manually recreate the image for the container to have the new changes, as my Dockerfile directly copies these into the container before building the image. This workflow is slow for development, so bind mounts might be a better approach, but they are not recommended for production setups.
- `Caching`: refreshing concepts with Redis.
- `Linux environments`: refreshing the importance of file permissions when for example executing generate-htpasswd.sh. Docker container logs would inform of: `/docker-entrypoint.sh: Ignoring /docker-entrypoint.d/10-generate-htpasswd.sh, not executable`. The file had to be modified through `chmod`to enable execution in the context of Linux.
- `bash not installed in Docker environment`: trying to execute a file with a SheBang of `#!/bin/bash`wouldn't execute. `#!/bin/ash` (ash, not bash) does.
- `Using Nginx templating`: copy .conf.template files in `etc/nginx/templates`. On startup, the nginx entrypoint script scans this directory for files with *.template suffix by default, and it runs envsubst. The envsubst parse the template using the shell interpolation and replaces shell variables with values from environment variables. It outputs to a file in /etc/nginx/conf.d/.
If you’re using $var, and there’s no such env-var, it will stay as is in the output file. In the above file, $host and $remote_addr are such examples. We want them to stay as parameters in the output file, as they are parameters used by nginx.
Source: https://devopsian.net/p/nginx-config-template-with-environment-vars/
