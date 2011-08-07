# Add RVM's lib directory to the load path
$:.unshift(File.expand_path('./lib', ENV['rvm_path']))

# Load RVM's capistrano plugin
require "rvm/capistrano"

require 'bundler/capistrano'
# require 'capistrano/ext/multistage'

# Colours!!!!
require 'capistrano_colors'

set :application, "cmsforge"
set :repository, "git://github.com/cmsmadesimple/cmsforge.git"
set :branch, 'rails-31-upgrade'

set :rails_env, "production"
set :git_enable_submodules, 1

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/www/cmsmadesimple.org/dev"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion
set :scm, :git
#set :deploy_via, :remote_cache

set :user, "rails"
#set :ssh_options, { :forward_agent => true }
set :use_sudo, false
#set :sudo_password, nil
set :rvm_bin_path, "/usr/local/rvm/bin"

role :web, "web20.cmsmadesimple.org"
role :app, "web20.cmsmadesimple.org", :primary => true
role :db,  "web20.cmsmadesimple.org", :primary => true
set :keep_releases, 5

namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
  
  desc "Preserve files" 
  task :preserve_files, :roles => [:web] do
    run <<-CMD
      mkdir -p -m 775 #{releases_path} #{shared_path}/system &&
      mkdir -p -m 777 #{shared_path}/log &&
      mkdir -p -m 775 #{release_path}/config/initializers &&
      cp #{releases_path}/../database.yml #{release_path}/config/database.yml &&
      cp #{releases_path}/../amazon_s3.yml #{release_path}/config/amazon_s3.yml &&
      cp #{releases_path}/../hoptoad.rb #{release_path}/config/initializers/hoptoad.rb &&
      ln -s #{shared_path}/db/sphinx #{release_path}/db/
    CMD
  end
  
  desc "Configure the sphinx server"
  task :configure_sphinx, :roles => :app do
    run "cd #{current_path} && rake ts:rebuild RAILS_ENV=production"
  end
  
  desc "Stop the sphinx server"
  task :stop_sphinx , :roles => :app do
    run "cd #{current_path} && rake ts:stop RAILS_ENV=production"
  end

  desc "Start the sphinx server" 
  task :start_sphinx, :roles => :app do
    run "cd #{current_path} && rake ts:start RAILS_ENV=production"
  end

  desc "Restart the sphinx server"
  task :restart_sphinx, :roles => :app do
    stop_sphinx
    configure_sphinx
    start_sphinx
  end
end

after "deploy:update_files", "deploy:preserve_files"
after "deploy:symlink", "deploy:restart_sphinx"

namespace :delayed_job do
  desc "Starts the delayed_job worker"
  task :start, :roles => :app, :only => {:primary => true} do
    run "RAILS_ENV=production #{current_path}/script/delayed_job > /dev/null 2>&1 &"
  end
  
  desc "Stops the delayed_job worker"
  task :stop, :roles => :app, :only => {:primary => true} do
    sudo "kill `ps -ef | grep \"delayed_job\" | grep -v grep | awk '{print $2}'`"
  end
  
  desc "Restarts the delayed_job worker"
  task :restart, :roles => :app, :only => {:primary => true} do
    delayed_job.stop
    delayed_job.start
  end
end

#Dir[File.join(File.dirname(__FILE__), '..', 'vendor', 'gems', 'hoptoad_notifier-*')].each do |vendored_notifier|
#  $: << File.join(vendored_notifier, 'lib')
#end

#require 'hoptoad_notifier/capistrano'
