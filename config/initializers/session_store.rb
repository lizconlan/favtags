# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_favtags_session',
  :secret      => 'c54be5eb622f41490fee0d33d0ca9e33328e948ee1a350db65c90b912c98576d5ecaa300af9d0aecc236f24caf511ef1e812b55619224a14d8b786a81aa987be'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
