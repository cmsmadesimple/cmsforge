SimpleConfig.for :application do
  set :host, 'http://dev.cmsmadesimple.org/'
  set :send_bcc, true
  set :create_git_repos, "/var/www/cmsmadesimple.org/dev/create_git_repos.sh "
  set :create_svn_repos, "/var/www/cmsmadesimple.org/dev/create_svn_repos.sh "
  set :drop_git_repos, "/var/www/cmsmadesimple.org/dev/drop_git_repos.sh "
  set :drop_svn_repos, "/var/www/cmsmadesimple.org/dev/drop_svn_repos.sh "
end