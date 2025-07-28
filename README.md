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
- Understand how to deploy the whole stack and how to scale it using AWS.
- Add hot reload to the entire development environment (if possible).