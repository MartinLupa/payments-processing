To install

```bundle install```

To execute just the web app

```rerun rackup -p 3000```

To execute using the Procfile

```foreman start```


# TODO
- Add nginx reverse proxy. DONE
- Add an authentication middleware. DONE
- Add environment variables to support different environments to the entire setup.
- How to log. Shared logger between Rack and Sidekiq? Where does the app writes the logs? How to export them to Loki?
- Understand how to deploy the whole stack and how to scale it using AWS.
- Understand the Sidekiq worker in detail and enhance it. Better way of error handling?
- Add hot reload to the entire development environment (if possible).