module TwitterAuth
  class Error < StandardError; end

  def self.config(environment=RAILS_ENV)
    @config ||= {}
    @config[environment] ||= YAML.load(File.open(RAILS_ROOT + '/config/twitter_auth.yml').read)[environment]
  end

  def self.encryption_key
    raise TwitterAuth::Cryptify::Error, 'You must specify an encryption_key in config/twitter_auth.yml' if config['encryption_key'].blank?
    config['encryption_key'] 
  end

  def self.oauth_callback?
    config.key?('oauth_callback')
  end

  def self.oauth_callback
    config['oauth_callback']
  end

  def self.remember_for
    (config['remember_for'] || 14).to_i
  end

  # The authentication strategy employed by this
  # application. Set in +config/twitter.yml+ as
  # strategy; valid options are oauth or basic.
  def self.strategy
    strat = config['strategy']
    raise ArgumentError, 'Invalid TwitterAuth Strategy: Valid strategies are oauth and basic.' unless %w(oauth basic).include?(strat)
    strat.to_sym
  rescue Errno::ENOENT
    :oauth
  end

  def self.oauth?
    strategy == :oauth
  end
  
  # The OAuth consumer used by TwitterAuth for authentication. The consumer key and secret are set in your application's +config/twitter.yml+
  def self.consumer
    options = {:site => "https://api.twitter.com"}
    [ :authorize_path, 
      :request_token_path,
      :access_token_path,
      :scheme,
      :signature_method ].each do |oauth_option|
      options[oauth_option] = TwitterAuth.config[oauth_option.to_s] if TwitterAuth.config[oauth_option.to_s]
    end

    OAuth::Consumer.new(
      config['oauth_consumer_key'],          
      config['oauth_consumer_secret'],
      options 
    )
  end
end

require 'twitter_auth/controller_extensions'
require 'twitter_auth/cryptify'
