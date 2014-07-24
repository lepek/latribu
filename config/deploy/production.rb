server 'latriburosario.com', user: 'deployer', roles: %w{web app db}

set :ssh_options, { forward_agent: false}