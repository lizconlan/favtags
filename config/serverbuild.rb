load File.expand_path(File.dirname(__FILE__) + '/virtualserver/deploy_secrets.rb')

namespace :serverbuild do
  set :user, root_user
  set :password, root_password
  
  task :user_setup, :roles => :app do
    sudo "mysqladmin -u root password \"#{sql_server_password}\""
    create_deploy_user
    sudo "chown #{deployuser} #{deploy_to}"
    sudo "chown #{deployuser} #{deploy_to}/*"
  end
  
  task :setup_apache, :roles => :app do
    source = File.read("config/apache.appconfig.example")
    data = ""
    source.each { |line|
      line.gsub!("[RELEASE-PATH]", deploy_to)
      data << line
    }
    put data, "/etc/apache2/sites-available/#{application}", :mode => 0664

    sudo "sudo ln -s -f /etc/apache2/sites-available/#{application} /etc/apache2/sites-enabled/000-default"
  end
end