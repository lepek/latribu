server 'latriburosario.com', user: 'deployer', roles: %w{web app db}

set :ssh_options, { forward_agent: false}

set :nginx_server_name, "clases.latriburosario.com"
set :unicorn_user, "nginx"
