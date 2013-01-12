require 'bundler/capistrano'

set :application, "texapp.org"

set :repository,  "git@github.com:texapp/web.git"
set :scm, :git

default_run_options[:pty] = true
set :user, 'thin'
ssh_options[:forward_agent] = true
set :use_sudo, false

set :deploy_via, :remote_cache
set :deploy_to, "/var/www/texapp.org"

role :web, "texapp.org"
role :app, "texapp.org"

namespace :deploy do
  task :start, :roles => [:web, :app] do
    run "cd #{deploy_to}/current && nohup thin -C thin/production.yml -R config.ru start"
  end
 
  task :stop, :roles => [:web, :app] do
    run "cd #{deploy_to}/current && nohup thin -C thin/production.yml -R config.ru stop"
  end
 
  task :restart, :roles => [:web, :app] do
    deploy.stop
    deploy.start
  end
 
  task :cold do
    deploy.update
    deploy.start
  end
end
