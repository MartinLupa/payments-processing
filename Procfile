web: bundle exec rerun rackup
worker: bundle exec sidekiq -C ./config/sidekiq.yml -r ./workers/payment_processor_worker.rb