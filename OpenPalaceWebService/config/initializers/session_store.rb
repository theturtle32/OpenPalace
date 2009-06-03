# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_OpenPalaceWebService_session',
  :secret      => '99fe48cb90ea55b75bfe957ac530fb7ef26c06d41fb2b1f15fba51a0577c3dc27fab304044d2516930bdbd10c392b1cede0f014215ac5cec188c75aabe870972'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
