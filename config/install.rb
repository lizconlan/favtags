# Require our stack
%w(essential apache scm ruby mysql rails).each do |r|
  require File.join(File.dirname(__FILE__), 'stack', r)
end

# What we're installing to your server
# Take what you want, leave what you don't
# Build up your own and strip down your server until you get it right. 
policy :passenger_stack, :roles => :app do
  requires :webserver               # Apache

  requires :apache_etag_support     # == Apache extras
  requires :apache_deflate_support  # Read about these specialties in 
  requires :apache_expires_support  # stack/apache.rb

  requires :appserver               # Passenger
  requires :ruby_enterprise         # Ruby
  requires :rails                   # Rails
  requires :database                # MySQL or Postgres
  requires :ruby_database_driver    # mysql or postgres gems
  requires :scm                     # Git
end

deployment do  
  # mechanism for deployment
  delivery :capistrano do
    begin
      recipes 'Capfile'
    rescue LoadError
      recipes 'deploy'
    end
  end
 
  # source based package installer defaults
  source do
    prefix   '/usr/local'
    archives '/usr/local/sources'
    builds   '/usr/local/build'
  end
end
