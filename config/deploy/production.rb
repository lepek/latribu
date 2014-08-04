set :stage, :production
server 'latriburosario.com', user: 'deployer', roles: %w{web app db}

set :ssh_options, { forward_agent: false}

set :nginx_server_name, "clases.latriburosario.com"
#set :unicorn_user, "nginx"

# dont try and infer something as important as environment from
# stage name.
set :rails_env, :production
