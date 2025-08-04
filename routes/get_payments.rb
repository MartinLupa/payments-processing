module PaymentHandlers
  def self.get_payments(res)
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
end
