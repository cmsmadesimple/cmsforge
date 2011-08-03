# Be sure to restart your server when you modify this file.

#Cmsforge::Application.config.session_store :cookie_store, key: '_cmsforge_session'

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Cmsforge::Application.config.session_store :active_record_store
require 'action_dispatch/middleware/session/dalli_store'
 
Cmsforge::Application.config.session_store :dalli_store, 
  :memcache_server => '127.0.0.1:11211', 
  :namespace => 'sessions', 
  :key => '_cmsforge_memcache_session', 
  :expire_after => 30.minutes
