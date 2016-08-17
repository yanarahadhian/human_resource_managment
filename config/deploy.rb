require 'capistrano/ext/multistage'
require "bundler/capistrano"

set :stages, %w(production staging)
set :default_stage, "production"
set :repository,  "git@wgs.unfuddle.com:wgs/hrm.git"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
set :template_dir, "config/deploy/templates/"
set :shared_configs, %w(database.yml)
set :shared_folders, %w()

set :keep_releases, 3
default_run_options[:pty] = true

set :use_sudo, false
set :deploy_via, :remote_cache
set :branch, "master"
set :scm_verbose, true

ssh_options[:forward_agent] = true

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

before "deploy", "deploy:activate_maintenance_page"
before "deploy", "utils:backup"
after "deploy:bundle_gems", "deploy:restart"
after "deploy:update_code", "deploy:symlink_shared"
after "deploy:update_code", "deploy:migrate"
after "deploy:update_code", "deploy:deactivate_maintenance_page"

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :my_migrate do
    run "cd #{current_path} && bundle exec gem --version"
  end

  task :bundle_gems do
    run "cd #{deploy_to}/current && bundle install"
  end

  task :configs_setup, :except => { :no_release => true } do
    shared_configs.each do |config|
      location = fetch(:template_dir, "config/deploy") + "#{config}.erb"
      puts "#{location}: #{File.file?(location)}"
      File.file?(location) ? (template = File.read(location)) : next

      conf = ERB.new(template)

      run "mkdir -p #{shared_path}/config"
      put(conf.result(binding), "#{shared_path}/config/#{config}", {:via => :scp})
    end
  end

  task :start do ; end
  task :stop do ; end
  task :restart do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  task :symlink_shared do
    run "ln -nfs #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
  end

  task :activate_maintenance_page do
    file_stop_path = File.join(current_path,'tmp','stop.txt')
    if File.exists?(file_stop_path)
      run "touch #{file_stop}"
    end
  end

  task :deactivate_maintenance_page do
    file_stop_path = File.join(current_path,'tmp','stop.txt')
    if File.exists?(file_stop_path)
      run "rm -f #{file_stop_path}"
    end
  end
end

namespace :utils do
  desc 'Backup database before deploy'
  task :backup, :roles => :db, :only => {:primary => true} do
    run "mkdir -p #{backup_to}" # Create a backup folder unless exists

    # Primary backup filename
    filename = "#{backup_to}/#{application}_dbdump_#{Time.now.strftime("%m%d%Y%H%I%S")}.sql.gz"

    # Check if we've got database config
    if remote_file_exists?("#{deploy_to}/current/config/database.yml")
      text = capture("cat #{deploy_to}/current/config/database.yml")
      config = YAML::load(text)[rails_env]

      on_rollback { run "rm #{filename}" }
      run "mysqldump -u #{config['username']} -p #{config['database']} | gzip --best > #{filename}" do |ch, stream, out|
        password = Capistrano::CLI.password_prompt("Type your password: ")
        ch.send_data "#{password}\n" if out =~ /^Enter password:/
      end
    else
      logger.debug("[Backup] No configuration file was found.")
    end
  end
end

def remote_file_exists?(full_path)
  'true' ==  capture("if [ -e #{full_path} ]; then echo 'true'; fi").strip
end