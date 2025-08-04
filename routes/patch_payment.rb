module PaymentHandlers
  def self.patch_payment(req, res, redis, id)
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
