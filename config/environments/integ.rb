SlinggitWebapp::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = true

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # See everything in the log (default is :info)
  config.log_level = :info

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false
  config.action_mailer.delivery_method = :sendmail

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5

  PROD_ENV = true
  HOSTURL = "integ.slinggit.com" # I'll be switching this shortly
  BASEURL = "https://#{HOSTURL}"
  POST_PHOTO_URL = "/uploads"
  POST_PHOTO_DIR = "/home/slinggit/webapps/slinggit_test/shared/uploads" # I'll be switching this shortly

  #  Our consumer key and secret for our twitter app (PROD)
  config.twitter_consumer_key = 'exOxe0rmGNEBBGsyW9nCA'
  config.twitter_consumer_secret = 'rwN7VmydrgRlRdb0kev1XxRi30YSpXHI7oXQEpPgUE'

  #  Facebook app id and secret
  config.facebook_app_id = '187772238018779'
  config.facebook_app_secret = 'a9665d164c1de339c773bfcb55368604'

  # @slinggit's authentication token and password, generated from the above consumer
  # key and secret.
  config.slinggit_client_atoken = '561831843-GXxjNVqaA1mTId1g61VXEyywDNBIUnsZ6mbUsvUa'
  config.slinggit_client_asecret = 'yOe5hXiG5vNLGWkJc11UFTiQyFC7ciH5OsFLMFSJfI'
  config.slinggit_username = 'slinggit'

  ## Twitter handles not tied to users ##
  SLINGGIT_HANDEL_USERNAME = 'slinggit'

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
