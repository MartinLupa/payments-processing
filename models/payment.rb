require 'sequel'

unless DB.table_exists?(:payments)
  DB.create_table? :payments do
    primary_key :id
    String :order_id, null: false
    Float :amount, null: false
    String :status, null: false, default: 'pending'
    String :card_token, null: false
    String :transaction_id, null: false, unique: true
    DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
    DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP

    index :order_id
  end
end

unless DB.indexes(:payments) { |index| index[:name] == :idx_payments_transaction_id }
  DB.add_index :payments, :transaction_id, unique: true, name: :idx_payments_transaction_id
end

##
# Payment model represents a payment transaction in the system.
# It includes fields for order ID, amount, status, card token, and transaction ID.
#
# It uses Sequel for ORM and provides basic functionality to interact with the payments table.
#
class Payment < Sequel::Model
  plugin :json_serializer
  plugin :validation_helpers
  def validate
    super
    validates_presence %i[order_id amount status transaction_id]
    validates_numeric :amount
    validates_min_value 0, :amount
  end
end
