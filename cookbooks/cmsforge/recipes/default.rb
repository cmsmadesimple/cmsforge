include_recipe "passenger_apache2"

web_app "cmsforge" do
  docroot "/var/www/default/public"
  server_name "localhost:8082"
  server_aliases [ node[:hostname], "cmsforge" ]
  rails_env "development"
end

gem_package "bundler" do
  gem_binary "/usr/local/bin/gem"
end

package "nodejs" do
  action :install
end

package "sphinxsearch" do
  action :install
end

execute "bundle install" do
  command "bundle install"
  cwd "/var/www/default"
end
