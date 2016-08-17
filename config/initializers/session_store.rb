# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_inventory_managemnet_session',
  :secret      => '558cc8c35c2483f240a9204ebd3c97df4ca63dad0456eb558e975ea0fba63e801e7b20aae11e60bd48886e604cee47611b55aef0931436f3f069f712d4a1baee'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
