set :application, "cmsforge"
set :repository,  "http://svn.cmsmadesimple.org/svn/cmsforge/trunk"

role :app, "lt10.cmsmadesimple.org"
role :web, "lt10.cmsmadesimple.org"
role :db,  "lt10.cmsmadesimple.org", :primary => true

set :user, "rails"
set :deploy_to, "/var/www/cmsmadesimple.org/dev"

ssh_options[:paranoid] = false 

set :scm_command, "/usr/bin/svn"
#set :local_scm_command, "/opt/local/bin/svn"

desc "The spinner task is used by :cold_deploy to start the application up"
task :spinner, :roles => :app do
  run "cd #{deploy_to}/#{current_dir} && mongrel_rails cluster::start -C #{mongrel_conf}"
end

desc "Restart the mongrel cluster"
task :restart, :roles => :app do
  run "cd #{deploy_to}/#{current_dir} && mongrel_rails cluster::restart -C #{mongrel_conf}"
end
