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
# default_run_options[:pty] = true
#ssh_options[:forward_agent] = true

set :keep_releases, 20

namespace :deploy do
  %w[start stop restart].each do |command|
    desc "#{command} unicorn server"
    task command do
      on roles(:app), except: {no_release: true} do
      execute "/etc/init.d/unicorn_#{fetch(:application)} #{command}"
    end
  end
end

task :setup_config do
  on roles(:app) do
    execute "mkdir -p #{shared_path}/config"
    # execute File.read("config/database.example.yml"), "#{shared_path}/config/database.yml"
    sudo "ln -nfs #{current_path}/config/nginx.conf /etc/nginx/sites-enabled/#{fetch(:application)}"
    sudo "ln -nfs #{current_path}/config/unicorn_init.sh /etc/init.d/unicorn_#{fetch(:application)}"
  end
end


task :symlink_config do
  on roles(:app) do
    execute "ln -nfs #{release_path}/config/database.example.yml #{shared_path}/config/database.yml"
    execute "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
end


desc "Make sure local git is in sync with remote."
task :check_revision do
  on roles(:web) do
    `git describe --tags --abbrev=0 > version`
    unless `git rev-parse HEAD` == `git rev-parse origin/master`
      puts "WARNING: HEAD is not the same as origin/master"
      puts "execute `git push` to sync changes."
      exit
    end
  end
end

task :write_version do
  on roles(:app) do
    upload! "./version", "#{release_path}/"
  end
end

before "deploy:symlink_config", "deploy:setup_config"
after 'deploy:updating', "deploy:symlink_config"
after "deploy:symlink_config", 'deploy:write_version'
before "deploy", "deploy:check_revision"
end
#hooks
after 'deploy', 'deploy:cleanup'
