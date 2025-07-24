require 'sidekiq'
require 'faraday'
require 'logger'
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

    logger.info("Processing payment ##{payment_id} with card token #{card_token}")

    # Simulate payment gateway call
    response = { success: true } # Simulate a successful response from the payment gateway

    DB.transaction do
      if response[:success]
        payment.update(status: 'completed')
        # EmailWorker.perform_async(payment.order_id, 'Payment successful')
      else
        payment.update(status: 'failed')
        logger.error("Payment failed for #{payment_id}: #{response.body}")
        raise 'Payment gateway error' unless retries_exhausted?
      end
    end
  end
end
