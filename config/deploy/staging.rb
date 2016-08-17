server '46.137.213.1', :app, :web, :db, :primary => true
set :application, "hrm"
set :rails_env, "production"
set :applicationdir, "/home/testing/htdocs/#{application}"
set :user, "testing"
set :rails_env, 'staging'
# Place where all backups will be dumped
set :backup_to, "#{applicationdir}/shared/backups"
set :deploy_to, applicationdir
set :database, {:name => 'hrm_testing', :user => 'hrm_testing'}
