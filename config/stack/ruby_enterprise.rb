package :ruby_enterprise do
  description 'Ruby Enterprise Edition'
  version '1.8.7-2010.02'
  REE_PATH = "/usr/local/ruby-enterprise"

  binaries = %w(erb gem irb rackup rails rake rdoc ree-version ri ruby testrb)
  source "http://rubyforge.org/frs/download.php/71096/ruby-enterprise-#{version}.tar.gz" do
    custom_install 'sudo ./installer --auto=/usr/local/ruby-enterprise'
    binaries.each {|bin| post :install, "ln -s #{REE_PATH}/bin/#{bin} /usr/local/bin/#{bin}" }
    post :install, "ln -s #{REE_PATH}/lib/ruby /usr/local/lib/ruby"
  end

  verify do
    has_directory install_path
    has_executable "#{REE_PATH}/bin/ruby"
    binaries.each {|bin| has_symlink "/usr/local/bin/#{bin}", "#{REE_PATH}/bin/#{bin}" }
  end

  requires :ree_dependencies
end

package :ree_dependencies do
  apt %w(zlib1g-dev libreadline5-dev libssl-dev)
  requires :build_essential
end

package :rubygems do
  description 'Ruby Gems Package Management System'
  version '1.3.7'
  source "http://rubyforge.org/frs/download.php/70696/rubygems-#{version}.tgz" do
    custom_install 'ruby setup.rb'
  end
  requires :ruby_enterprise
end