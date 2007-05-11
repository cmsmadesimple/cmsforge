set :application, "cmsforge"
set :repository,  "http://svn.cmsmadesimple.org/svn/cmsforge/trunk"

role :app, "lt10.cmsmadesimple.org"
role :web, "lt10.cmsmadesimple.org"
role :db,  "lt10.cmsmadesimple.org", :primary => true

set :user, "rails"
set :deploy_to, "/var/www/cmsmadesimple.org/devtest"

ssh_options[:paranoid] = false 

set :scm_command, "/usr/bin/svn"
#set :local_scm_command, "/opt/local/bin/svn"
