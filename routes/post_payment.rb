module PaymentHandlers
  def self.post_payment(req, res)
    payload = JSON.parse(req.body.read)

    # Validate payload
    begin
      JSON::Validator.validate!(Schemas::PAYMENT_CREATE, payload)
    rescue JSON::Schema::ValidationError => e
      res.status = 400
      res.json({ data: nil, error: e.message })
    end

    # Extract parameters
    order_id = payload['order_id']
    amount = payload['amount']
    card_token = payload['card_token']

    # Generate unique transaction ID
    transaction_id = SecureRandom.uuid

    # Create payment record
    payment = Payment.create(order_id: order_id, amount: amount, status: 'pending', card_token: card_token,
                             transaction_id: transaction_id)
    # Enqueue payment processing
    PaymentProcessorWorker.perform_async(payment.id, card_token)

    res.status = 202
    res.json({ data: { message: 'Payment initiated', transaction_id: transaction_id, status: 'pending' },
               error: nil })
  end
end
