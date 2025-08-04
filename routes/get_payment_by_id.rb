module PaymentHandlers
  def self.get_payment_by_id(id, redis, res)
    # Check Redis cache
    cached = redis.get("payment:#{id}")

    if cached
      res.headers['etag'] = Digest::SHA1.hexdigest(cached)
      res.headers['cached'] = 'true'
      res.json(cached)
    end

    payment = Payment.where(transaction_id: id).first
    unless payment
      res.status = 404
      res.json({ data: nil, error: 'Payment not found' }.to_json)
    end

    response = payment.to_json

    redis.setex("payment:#{id}", 3600, response)
    res.headers['etag'] = Digest::SHA1.hexdigest(response)
    res.json({ data: response, error: nil })
  end
end
