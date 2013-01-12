require 'bundler/capistrano'

set :application, "texapp.org"

set :repository,  "git@github.com:texapp/web.git"
set :scm, :git
set :git_enable_submodules, 1

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
set :user, 'thin'
set :use_sudo, false

set :deploy_via, :remote_cache
set :deploy_to, "/var/www/texapp.org"

role :web, "texapp.org"
role :app, "texapp.org"

namespace :deploy do
  task :start, :roles => [:web, :app] do
    run "cd #{deploy_to}/current && nohup bundle exec thin -C thin/production.yml -R config.ru start"
  end
 
  task :stop, :roles => [:web, :app] do
    run "cd #{deploy_to}/current && nohup bundle exec thin -C thin/production.yml -R config.ru stop"
  end
 
  task :restart, :roles => [:web, :app] do
    deploy.stop
    deploy.start
  end
 
  task :cold do
    deploy.update
    deploy.start
  end

  task :symlink_credentials, :roles => :app do
    run "ln -nfs #{deploy_to}/shared/config/credentials.yml #{release_path}/config/credentials.yml"
  end
end

after 'deploy:update_code', 'deploy:symlink_credentials'
