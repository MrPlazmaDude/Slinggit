SlinggitWebapp::Application.configure do

  # Settings specified here will take precedence over those in config/application.rb

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Configure static asset server for tests with Cache-Control for performance
  config.serve_static_assets = true
  config.static_cache_control = "public, max-age=3600"

  # Log error messages when you accidentally call methods on nil
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :sendmail

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr

  # Speed up tests by lowering BCrypt's cost function.
  require 'bcrypt'
  silence_warnings do
    BCrypt::Engine::DEFAULT_COST = BCrypt::Engine::MIN_COST
  end

  PROD_ENV = false
  HOSTURL = "integ.slinggit.com"
  BASEURL = "http://#{HOSTURL}"
  POST_PHOTO_URL = "/uploads"
  POST_PHOTO_DIR = "/home/slinggit/webapps/slinggit_test/shared/uploads"

  #  Our consumer key and secret for our twitter app (DEV)
  config.twitter_consumer_key = 'uVUtXqE5xN5yVtZgLd5u3w'
  config.twitter_consumer_secret = 'TmguQ0JOAs0a3ILREjvlhSEM2Igi5S4hF86cQdxtG0'

  #  Facebook app id and secret
  config.facebook_app_id = '187772238018779'
  config.facebook_app_secret = 'a9665d164c1de339c773bfcb55368604'

  # @slinggit's authentication token and password, generated from the above consumer
  # Probably won't need this again in test, but just commenting out for now.
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
