SimpleConfig.for :application do
  set :host, 'http://devnew.cmsmadesimple.org/'
  set :send_bcc, true
  set :create_git_repos, "/var/www/cmsmadesimple.org/devnew/create_git_repos.sh "
  set :create_svn_repos, "/var/www/cmsmadesimple.org/devnew/create_svn_repos.sh "
end