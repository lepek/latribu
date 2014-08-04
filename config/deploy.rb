lock '3.2.1'

set :application, "latriburosario"

set :user, 'deployer'
set :deploy_to, "/home/#{fetch(:user)}/apps/#{fetch(:application)}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :repo_url,  "https://github.com/lepek/latribu.git"
set :scm, :git
set :branch, 'master'
set :pty, true
set :linked_files, %w{config/database.yml}

# default_run_options[:pty] = true
#ssh_options[:forward_agent] = true

set :keep_releases, 20

namespace :deploy do

  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:all) do
      `git describe --tags --abbrev=0 > version`
      unless `git rev-parse HEAD` == `git rev-parse origin/master`
        puts "WARNING: HEAD is not the same as origin/master"
        puts "execute `git push` to sync changes."
        exit
      end
    end
  end

  task :write_version do
    on roles(:all) do
      upload! "./version", "#{release_path}/"
    end
  end

  desc "Fix permission"
  task :fix_permissions do
    on roles(:all) do
      `chmod 775 -R #{current_path}/log`
    end
  end

  #after "deploy:published", "deploy:fix_permissions"
  after "deploy:updating", 'deploy:write_version'
  before "deploy", "deploy:check_revision"
end

#hooks
after 'deploy', 'deploy:cleanup'
