set :application, "cmsforge"
set :repository, "http://svn.cmsmadesimple.org/svn/cmsforge/trunk"

set :rails_env, "production"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/www/cmsmadesimple.org/devnew"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion
set :scm, :subversion
set :deploy_via, :remote_cache

set :user, "rails"
set :ssh_options, { :forward_agent => true }
set :use_sudo, false
set :sudo_password, nil

role :web, "web2.cmsmadesimple.org"
role :app, "web2.cmsmadesimple.org", :primary => true
role :db,  "web2.cmsmadesimple.org", :primary => true
set :keep_releases, 3

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
  task :after_update_code, :roles => [:web] do
    run <<-CMD
      mkdir -p -m 775 #{releases_path} #{shared_path}/system &&
      mkdir -p -m 777 #{shared_path}/log &&
      mkdir -p -m 775 #{release_path}/config/initializers &&
      cp #{releases_path}/../database.yml #{release_path}/config/database.yml &&
      cp #{releases_path}/../amazon_s3.yml #{release_path}/config/amazon_s3.yml &&
      cp #{releases_path}/../hoptoad.rb #{release_path}/config/initializers/hoptoad.rb
    CMD
  end

end

# =============================================================================
# FERRET
# =============================================================================
set :ferret_script_name, "ferret_#{application}_ctl"
set :ferret_ctl, "/etc/init.d/#{ferret_script_name}"

namespace :ferret do
  desc "Uploads the ferret startup script"
  task :install, :roles => :app, :only => {:primary => true} do 
    require 'erb'
    upload_path = "#{shared_path}/ferret" 
    template = File.read("config/templates/ferret_ctl.erb")
    file = ERB.new(template).result(binding) 
    put file, upload_path, :mode => 0755
    sudo "cp #{upload_path} #{ferret_ctl}"
    sudo "chmod +x #{ferret_ctl}"
    sudo "/usr/sbin/update-rc.d #{ferret_script_name} defaults"
  end 

  desc "Starts the ferret server"
  task :start, :roles => :app, :only => {:primary => true} do
    sudo "#{ferret_ctl} start"
  end

  desc "Stops the ferret server"
  task :stop, :roles => :app, :only => {:primary => true} do
    sudo "#{ferret_ctl} stop"
  end

  desc "Restarts the ferret server"
  task :restart, :roles => :app, :only => {:primary => true} do
    ferret.stop
    ferret.start
  end
  
  desc "Deletes the ferret startup script"
  task :uninstall, :roles => :app, :only => {:primary => true} do 
    sudo "/usr/sbin/update-rc.d -f #{ferret_script_name} remove"
    sudo "rm -rf #{ferret_ctl}"
  end 
  
end
after "deploy:symlink", "ferret:restart"
