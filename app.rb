require 'cuba'
require 'json'
require 'securerandom'
require 'redis'
require 'sidekiq/web'
require './models/payment'
require './workers/payment_processor_worker'

# Cuba.use Rack::Auth::Basic do |username, password|
#   username == 'user1' &&
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
      res.write({ transaction_id: transaction_id, status: 'pending' }.to_json)
    end

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

      res.json({ message: payments.empty? ? 'No payments found' : payments })
    end

    on ':id' do |id|
      on get do
        # Check Redis cache
        cached = redis.get("payment:#{id}")
        if cached
          res.headers['etag'] = Digest::SHA1.hexdigest(cached)
          res.json(message: 'cached', data: cached)
          next
        end

        payment = Payment.where(transaction_id: id).first
        unless payment
          res.status = 404
          res.json({ error: 'Payment not found' }.to_json)
          next
        end

        # Cache response for 1 hour
        response = payment.to_json
        redis.setex("payment:#{id}", 3600, response)
        res.headers['etag'] = Digest::SHA1.hexdigest(response)
        res.headers['cache-control'] = 'max-age=3600'
        res.json(response)
      end
    end
  end
end
