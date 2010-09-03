SimpleConfig.for :application do
  set :host, 'http://localhost:3000/'
  set :send_bcc, false
  set :create_git_repos, "touch /tmp/tmp_git_"
  set :create_svn_repos, "touch /tmp/tmp_svn_"
  set :drop_git_repos, "touch /tmp/delete_tmp_git_"
  set :drop_svn_repos, "touch /tmp/delete_tmp_svn_"
end