require 'sequel'
DB = Sequel.connect(ENV['DB_URL'] || raise('Missing DB_URL environment variable.'))
