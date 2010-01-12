load File.expand_path(File.dirname(__FILE__) + '/virtualserver/deploy_secrets.rb')

set :application, "favtags"
set :repository,  "git://github.com/lizconlan/favtags.git"
set :branch, "master"
set :scm, :git

ssh_options[:forward_agent] = true

role :app, domain
role :web, domain
role :db,  domain, :primary => true

namespace :deploy do
  set :user, deployuser
  set :password, deploypassword
  set :runner, user
  
  desc "Upload deployed database.yml"
  task :upload_deployed_database_yml, :roles => :app do
    data = File.read("config/virtualserver/deployed_database.yml")
    put data, "#{release_path}/config/database.yml", :mode => 0664
  end
  
  desc "Set up log dir"
  task :setup_log_dir do
    log_dir = "#{deploy_to}/shared/"
    run "if [ -d #{log_dir} ]; then echo #{log_dir} exists ; else mkdir #{log_dir} ; fi"
    log_dir = "#{deploy_to}/shared/log"
    run "if [ -d #{log_dir} ]; then echo #{log_dir} exists ; else mkdir #{log_dir} ; fi"
  end
  
  desc "Restarting apache and clearing the cache"
  task :restart, :roles => :app do
    sudo "/usr/sbin/apache2ctl restart"
  end
end

after 'deploy:update_code', 'deploy:upload_deployed_database_yml', 'deploy:setup_log_dir'
