load File.expand_path(File.dirname(__FILE__) + '/virtualserver/deploy_secrets.rb')

# Fill slice_url in - where you're installing your stack to
role :app, domain

# Fill user in - if remote user is different to your local user
set :user, root_user
set :password, root_password

set :repository, "git://github.com/lizconlan/favtags.git"
set :scm, :git
set :deploy_via, :remote_cache

set :runner, deployuser

ssh_options[:forward_agent] = true

default_run_options[:pty] = true

set :application, 'favtags'

namespace :deploy do
  set :user, deployuser
  set :password, deploypassword
  
  desc "Upload deployed database.yml"
  task :upload_deployed_database_yml, :roles => :app do
    data = File.read("config/virtualserver/deployed_database.yml")
    put data, "#{release_path}/config/database.yml", :mode => 0664
  end
  
  desc "Upload bitly.yml"
  task :upload_bitly_yml, :roles => :app do
    data = File.read("config/virtualserver/bitly.yml")
    put data, "#{release_path}/config/bitly.yml", :mode => 0664
  end
  
  desc "Upload twitter_auth.yml"
  task :upload_twitter_auth_yml, :roles => :app do
    data = File.read("config/twitter_auth.yml")
    put data, "#{release_path}/config/twitter_auth.yml", :mode => 0664
  end
  
  task :link_to_data, :roles => :app do
    data_dir = "#{deploy_to}/shared/cached-copy/data"
    run "if [ -d #{data_dir} ]; then ln -s #{data_dir} #{release_path}/data ; else echo cap deploy put_data first ; fi"
    
    log_dir = "#{deploy_to}/shared/log"
    run "if [ -d #{log_dir} ]; then echo #{log_dir} exists ; else mkdir #{log_dir} ; touch #{log_dir}/production.log ; chmod 0666 #{log_dir}/production.log; fi"

    run "if [ -d #{deploy_to}/shared/system ]; then echo exists ; else mkdir #{deploy_to}/shared/system ; fi"
    sudo "chmod a+rw #{release_path}/public/stylesheets"
  end
  
  task :run_migrations, :roles => :app do
    run "cd #{release_path}; rake db:create:all"
    run "cd #{release_path}; rake db:migrate RAILS_ENV=production"
  end
  
  task :install_gems, :roles => :app do
    sudo "gem install json"
    sudo "gem install oauth"
    sudo "gem install ezcrypto"
    sudo "gem install will_paginate"
    sudo "gem install haml"
    sudo "gem install rest-client"
    sudo "gem install daemons"
  end
  
  desc "Restarting apache and clearing the cache"
  task :restart, :roles => :app do
    sudo "/usr/sbin/apache2ctl restart"
  end
end

after 'deploy:setup', 'serverbuild:user_setup', 'serverbuild:setup_apache', 'deploy:install_gems'
after 'deploy:update_code', 'deploy:upload_deployed_database_yml', 'deploy:upload_bitly_yml', 'deploy:upload_twitter_auth_yml', 'deploy:link_to_data'
after 'deploy:symlink', 'deploy:run_migrations'
after "deploy:stop",    "delayed_job:stop"
after "deploy:start",   "delayed_job:start"
after "deploy:restart", "delayed_job:restart"

def create_deploy_user
  create_user deployuser, deploygroup, deploypassword
end

def create_user username, group, newpassword
  begin
    sudo "grep '^#{group}:' /etc/group"
  rescue
    sudo "groupadd #{group}"
  end

  begin
    sudo "grep '^#{username}:' /etc/passwd"
  rescue
    sudo "useradd -g #{group} -s /bin/bash #{username}"
  end

  change_password username, newpassword

  run "if [ -d /home/#{username} ]; then echo exists ; else echo not found ; fi", :pty => true do |ch, stream, data|
    if data =~ /not found/
      sudo "mkdir /home/#{username}"
      sudo "chown #{username} /home/#{username}"
    end
  end
end

def change_password username, newpassword
  run "sudo passwd #{username}", :pty => true do |ch, stream, data|
    puts data
    if data =~ /Enter new UNIX password:/ or data =~ /Retype new UNIX password:/
      ch.send_data(newpassword + "\n")
    else
      Capistrano::Configuration.default_io_proc.call(ch, stream, data)
    end
  end
end

def put_data data_dir, file
  data_file = "#{data_dir}/#{file}"

  run "if [ -f #{data_file} ]; then echo exists ; else echo not there ; fi" do |channel, stream, message|
    if message.strip == 'not there'
      puts "sending #{file}"
      data = File.read("data/#{file.gsub('\\','')}")
      put data, "#{data_file}", :mode => 0664
    else
      puts "#{file} #{message}"
    end
  end
end


namespace :delayed_job do  
  def rails_env
    fetch(:rails_env, false) ? "RAILS_ENV=#{fetch(:rails_env)}" : ''
  end
  
  task :stop, :roles => :app do
    run "cd #{current_path};#{rails_env} script/delayed_job stop"
  end

  desc "Start the delayed_job process"
  task :start, :roles => :app do
    run "cd #{current_path};#{rails_env} script/delayed_job start"
  end

  desc "Restart the delayed_job process"
  task :restart, :roles => :app do
    run "cd #{current_path};#{rails_env} script/delayed_job restart"
  end
end