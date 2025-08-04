require 'cuba'
require 'cuba/safe'
require 'redis'
require 'sidekiq/web'
require './config/database'
require './config/opentelemetry'
require './middlewares/error_handler'
require './models/payment'
require './routes/post_payment'
require './routes/get_payments'
require './routes/get_payment_by_id'
require './routes/patch_payment'
require './schemas/payment'
require './workers/payment_processor_worker'

##
# Uncomment the following lines to enable basic authentication
# For the time being, authentication is happening at the API Gateway level.
# Replace with JWT or API key in production
#
# Cuba.use Rack::Auth::Basic do |username, password|
#   username == 'user' &&
#     password == 'password' # Replace with JWT or API key in production
# end

Cuba.use ErrorHandler

Cuba.define do
  redis = Redis.new

  on 'payments' do
    on root, get do
      PaymentHandlers.get_payments(res)
    end

    on post do
      PaymentHandlers.post_payment(req, res)
    end

    on ':id' do |id|
      on get do
        PaymentHandlers.get_payment_by_id(id, redis, res)
      end

      on patch do
        PaymentHandlers.patch_payment(req, res, redis, id)
      end
    end
  end
end
