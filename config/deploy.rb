set :application, "cmsforge"
set :repository, "http://svn.cmsmadesimple.org/svn/cmsforge/trunk"

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

role :web, "web2.cmsmadesimple.org"
role :app, "web2.cmsmadesimple.org"
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
      cp #{releases_path}/../database.yml #{release_path}/config/database.yml &&
      cp #{releases_path}/../amazon_s3.yml #{release_path}/config/amazon_s3.yml &&
      cp #{releases_path}/../hoptoad.rb #{release_path}/config/initializers/hoptoad.rb
    CMD
  end

end
