# Payments Processing API

A lightweight payments processing microservice built with Ruby/Cuba, featuring asynchronous payment processing, caching, and API gateway functionality.

## Architecture

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

