set :application, "cmsforge"
set :repository,  "http://svn.cmsmadesimple.org/svn/cmsforge/trunk"

role :app, "lt10.cmsmadesimple.org"
role :web, "lt10.cmsmadesimple.org"
role :db,  "lt10.cmsmadesimple.org", :primary => true

set :user, "rails"
set :deploy_to, "/var/www/cmsmadesimple.org/dev"
set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"

set :scm_command, "/usr/bin/svn"
#set :local_scm_command, "/opt/local/bin/svn"

ssh_options[:paranoid] = false 

namespace :deploy do
  desc "Starts the mongrel cluster"
  task :start, :roles => :app do
    run "cd #{current_path} && mongrel_rails cluster::start -C #{mongrel_conf}"
  end

  desc "Restart the mongrel cluster"
  task :restart, :roles => :app do
    run "cd #{current_path} && mongrel_rails cluster::restart -C #{mongrel_conf}"
  end

  desc "Stops the mongrel cluster"
  task :stop, :roles => :app do
    run "cd #{current_path} && mongrel_rails cluster::stop -C #{mongrel_conf}"
  end
end
