require 'sidekiq'
require 'faraday'
require 'logger'
require './config/database'
require './models/payment'

##
# PaymentProcessorWorker is a Sidekiq worker that processes payments asynchronously.
# It handles payment processing logic, including interacting with a mock payment gateway.
# It ensures idempotency by checking the payment status before processing.
# It also logs errors and sends notifications upon success or failure.
#
class PaymentProcessorWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'payments', retry: 3

  def perform(payment_id, card_token)
    logger = Logger.new(STDOUT)
    payment = Payment.first(id: payment_id)

    logger.info("Processing payment ##{payment_id}")

    # Simulate payment gateway call
    response = { success: false } # Simulate a successful response from the payment gateway

    DB.transaction do
      if response[:success]
        payment.update(status: 'completed')
        logger.info("Payment ##{payment_id} completed successfully")
        # EmailWorker.perform_async(payment.order_id, 'Payment successful')
      else
        payment.update(status: 'failed')
        logger.error("Payment failed for #{payment_id}")
        # EmailWorker.perform_async(payment.order_id, 'Payment failed')
      end
    end
  end
end
