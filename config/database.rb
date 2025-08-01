require 'sequel'
require 'dotenv/load' if defined?(Dotenv)

# Load environment variables
database_url = ENV['DATABASE_URL']

if database_url.nil? || database_url.empty?
  # Fallback to individual environment variables
  db_host = ENV['DB_HOST'] || 'localhost'
  db_port = ENV['DB_PORT'] || '5432'
  db_name = ENV['DB_NAME'] || 'payments'
  db_user = ENV['DB_USER'] || 'postgres'
  db_password = ENV['DB_PASSWORD'] || ''

  database_url = "postgres://#{db_user}:#{db_password}@#{db_host}:#{db_port}/#{db_name}"
end

begin
  DB = Sequel.connect(database_url)

  # Test the connection
  DB.test_connection

  # Configure connection pool
  DB.extension :connection_validator
  DB.pool.connection_validation_timeout = 3600

  puts "✅ Database connected successfully to #{database_url.gsub(/:[^:@]*@/, ':***@')}"
rescue Sequel::DatabaseConnectionError => e
  puts "❌ Database connection failed: #{e.message}"
  puts "Database URL: #{database_url}"
  raise e
end
