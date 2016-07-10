lock '3.4.0'

set :application, "latriburosario"

set :user, 'deployer'
set :deploy_to, "/home/#{fetch(:user)}/apps/#{fetch(:application)}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :repo_url,  "https://github.com/lepek/latribu.git"
set :scm, :git
set :branch, 'master'
set :pty, true
set :linked_files, %w{config/database.yml config/application.yml}

# default_run_options[:pty] = true
#ssh_options[:forward_agent] = true

set :keep_releases, 20

namespace :deploy do

  task :write_version do
    on roles(:all) do
      upload! "./version", "#{release_path}/"
    end
  end

  after "deploy:updating", 'deploy:write_version'
end

#hooks
after 'deploy', 'deploy:cleanup'
