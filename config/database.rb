require 'sequel'
require 'retriable'

database_url = ENV['DATABASE_URL']
raise '[Missing environment variable] DATABASE_URL' if database_url.nil? || database_url.empty?

Retriable.retriable(on: Sequel::DatabaseConnectionError, tries: 1, intervals: 1) do
  DB = Sequel.connect(database_url)

  DB.test_connection

  DB.extension :connection_validator
  DB.pool.connection_validation_timeout = 3600

  puts "✅ Database connected successfully to #{database_url.gsub(/:[^:@]*@/, ':***@')}"
rescue Sequel::DatabaseConnectionError => e
  puts "❌ Database connection failed: #{e.message}"
  puts "Database URL: #{database_url}"
  raise e
end
