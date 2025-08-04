require 'json-schema'

module Schemas
  PAYMENT_CREATE = {
    type: 'object',
    required: %w[order_id amount card_token],
    properties: {
      order_id: {
        type: 'string',
        minLength: 1
      },
      amount: {
        type: 'number',
        minimum: 0
      },
      card_token: {
        type: 'string',
        minLength: 1
      }
    },
    additionalProperties: false
  }.freeze
end
