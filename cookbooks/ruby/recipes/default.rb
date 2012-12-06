# case node['platform']
# when "ubuntu","debian"
#   package "ruby1.9.1-full" do
#     action :install
#   end

#   bash "update rubygems" do
#     only_if 'gem --version | grep "1.3"'
#     code <<-EOH
#       REALLY_GEM_UPDATE_SYSTEM=1 sudo gem update --system
#     EOH
#   end

#   gem_package "bundler"
# end

bash "install ruby" do
  not_if 'ruby --version | grep "1.9.3p286"'
  code <<-EOH
    cd /tmp
    wget http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p286.tar.gz
    tar xzf ruby-1.9.3-p286.tar.gz
    cd ruby-1.9.3-p286
    ./configure
    make
    sudo make install
  EOH
end

bash "install rubygems" do
  not_if 'gem --version | grep "1.8.24"'
  code <<-EOH
    cd /tmp
    wget http://production.cf.rubygems.org/rubygems/rubygems-1.8.24.tgz
    tar zxf rubygems-1.8.24.tgz
    cd rubygems-1.8.24
    sudo ruby setup.rb --no-format-executable
  EOH
end

gem_package "bundler"
