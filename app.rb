require 'cuba'
require 'json'
require 'securerandom'
require 'redis'
require 'sidekiq/web'
require './config/database'
require './models/payment'
require './workers/payment_processor_worker'

##
# Uncomment the following lines to enable basic authentication
# For the time being, authentication is happening at the API Gateway level.
# Replace with JWT or API key in production
#
# Cuba.use Rack::Auth::Basic do |username, password|
#   username == 'allowed-user' &&
#     password == 'secret' # Replace with JWT or API key in production
# end

Cuba.define do
  redis = Redis.new

  on 'health' do
    on get do
      res.headers['content-type'] = 'application/json'
      res.write({ status: 'ok', timestamp: Time.now.utc }.to_json)
    end
  end

  on 'payments' do
    on root, get do
      payments = Payment.all.map do |payment|
        {
          id: payment.id,
          order_id: payment.order_id,
          amount: payment.amount,
          status: payment.status,
          transaction_id: payment.transaction_id,
          created_at: payment.created_at,
          updated_at: payment.updated_at
        }
      end

      res.json({ data: payments.empty? ? 'No payments found' : payments, error: nil })
    end

    on post do
      params = JSON.parse(req.body.read)
      order_id = params['order_id']
      amount = params['amount']
      card_token = params['card_token']

      # Generate unique transaction ID
      transaction_id = SecureRandom.uuid

      # Create payment record
      payment = Payment.create(order_id: order_id, amount: amount, status: 'pending', card_token: card_token,
                               transaction_id: transaction_id)
      # Enqueue payment processing
      PaymentProcessorWorker.perform_async(payment.id, card_token)

      res.status = 202
      res.write({ data: { message: 'Payment initiated', transaction_id: transaction_id, status: 'pending' },
                  error: nil }.to_json)
    end

    on ':id' do |id|
      on get do
        # Check Redis cache
        cached = redis.get("payment:#{id}")

        if cached
          res.headers['etag'] = Digest::SHA1.hexdigest(cached)
          res.headers['cached'] = 'true'
          res.json(cached)
          next
        end

        payment = Payment.where(transaction_id: id).first
        unless payment
          res.status = 404
          res.json({ data: nil, error: 'Payment not found' }.to_json)
          next
        end

        response = payment.to_json

        redis.setex("payment:#{id}", 3600, response)
        res.headers['etag'] = Digest::SHA1.hexdigest(response)
        # res.headers['cache-control'] = 'max-age=3600'
        res.json({ data: response, error: nil })
      end

      on patch do
        params = JSON.parse(req.body.read)
        status = params['status']

        payment = Payment.where(transaction_id: id).first
        if payment
          updated_payment = payment.update(status: status)
          redis.setex("payment:#{id}", 3600, updated_payment.to_json) # Cache the updated payment status

          res.write({ data: { message: 'Payment status updated', transaction_id: id, status: status },
                      error: nil }.to_json)
        else
          res.status = 404
          res.write({ data: nil, error: 'Payment not found' }.to_json)
        end
      end
    end
  end
end
