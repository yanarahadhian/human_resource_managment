server '46.137.213.1', :app, :web, :db, :primary => true
set :application, "hr"
set :rails_env, "production"
set :applicationdir, "/home/deploy/projects/appschef/capistrano/hr"
set :user, "deploy"
# Place where all backups will be dumped
set :backup_to, "#{applicationdir}/shared/backups"
set :deploy_to, applicationdir
