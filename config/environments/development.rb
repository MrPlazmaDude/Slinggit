SlinggitWebapp::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  PROD_ENV = false
  HOSTURL = "localhost:3000"
  BASEURL = "http://#{HOSTURL}"
  POST_PHOTO_DIR = "#{Rails.root}/public/uploads"
  POST_PHOTO_URL = "/uploads"

  #  Our consumer key and secret for our twitter app (DEV)
  config.twitter_consumer_key = 'uVUtXqE5xN5yVtZgLd5u3w'
  config.twitter_consumer_secret = 'TmguQ0JOAs0a3ILREjvlhSEM2Igi5S4hF86cQdxtG0'

  #  Facebook app id and secret
  config.facebook_app_id = '187772238018779'
  config.facebook_app_secret = 'a9665d164c1de339c773bfcb55368604'

  # @slinggit's authentication token and password, generated from the above consumer
  # Probably won't need this again in dev, but just commenting out for now.
  # key and secret.
  # config.slinggit_client_atoken = '561831843-mHAqcKLJfFyCSQOXvlyH5fCvHRlRhRqMFDPNMS9h'
  # config.slinggit_client_asecret = 'T7yvd3FfhpVJacLS6zjFO3yrXl8HDurhfXLq3AQL8'

  # @gitnsling_test's authentication token and password, generated from the above consumer
  # key and secret.
  config.slinggit_client_atoken = '571885574-lYr8br0gkmLOaPSB5GRxGssQhpVlxZavksjFFWbQ'
  config.slinggit_client_asecret = 't6dzy6YrrG0I0STKvRRCyAqWrVqZiRNfqfzWNGbdxYI'
  config.slinggit_username = 'gitnsling_test'

   ## Twitter handles not tied to users ##
  SLINGGIT_HANDEL_USERNAME = 'gitnsling_test'

  ## Photo sources ##
  SLINGGIT_PHOTO_SOURCE = "SPS"
  TWITTER_PHOTO_SOURCE = "TPS"
  GRAVATAR_PHOTO_SOURCE = "GPS"
  FACEBOOK_PHOTO_SOURCE = "FPS"

  ## STATUSES ##
  STATUS_SUCCESS = "SUC"
  STATUS_UNVERIFIED = "UVR"
  STATUS_DELETED = "DEL"
  STATUS_CLOSED = "CLO"
  STATUS_BANNED = "BAN"
  STATUS_ACTIVE = "ACT"
  STATUS_SUSPENDED = "SUS"
  STATUS_OPEN = "OPN"
  STATUS_PENDING = "PND"
  STATUS_RESOLVED = "RES"
  STATUS_PRIMARY = "PRM"
  STATUS_UNREAD = "UNR"
  STATUS_READ = "RED"
  STATUS_FAILED = "FAL"
  STATUS_PROCESSING = "PRC"
  STATUS_ARCHIVED = "ARC"

  ## ROLES ##
  ROLE_ADMIN = "ADM"
  ROLE_EXTERNAL = "EXT"

  ## CLOSING REASONS ##
  ITEM_SOLD = "SLD"
  ITEM_NOT_SELLING = "NSL"
  ITEM_OTHER = "OTH"

end
