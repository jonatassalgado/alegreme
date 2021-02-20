require "active_support/core_ext/integer/time"

Rails.application.configure do
	# Settings specified here will take precedence over those in config/application.rb.

	# Code is not reloaded between requests.
	config.cache_classes = true

	# Eager load code on boot. This eager loads most of Rails and
	# your application in memory, allowing both threaded web servers
	# and those relying on copy on write to perform better.
	# Rake tasks automatically ignore this option for performance.
	config.eager_load = true

	# Full error reports are disabled and caching is turned on.
	config.consider_all_requests_local       = false
	config.action_controller.perform_caching = true

	# Ensures that a master key has been made available in either ENV["RAILS_MASTER_KEY"]
	# or in config/master.key. This key is used to decrypt credentials (and other encrypted files).
	# config.require_master_key = true

	# Disable serving static files from the `/public` folder by default since
	# Apache or NGINX already handles this.
	config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
	config.public_file_server.headers = {
			'Cache-Control' => 'public, max-age=31536000'
	}

	# Compress JavaScripts and CSS.
	config.assets.js_compressor = Uglifier.new(harmony: true)
	# config.assets.css_compressor = :sass

	# Do not fallback to assets pipeline if a precompiled asset is missed.
	config.assets.compile = true

	# `config.assets.precompile` and `config.assets.version` have moved to config/initializers/assets.rb

	# Enable serving of images, stylesheets, and JavaScripts from an asset server.
	#config.asset_host = 'd1w77y6tbawl69.cloudfront.net'

	# Specifies the header that your server uses for sending files.
	# config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
	# config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

	# Store uploaded files on the local file system (see config/storage.yml for options)
	config.active_storage.service = :local

	# Mount Action Cable outside main process or domain
	# config.action_cable.mount_path = nil
	config.action_cable.url                     = 'wss://www.alegreme.com/cable'
	config.action_cable.allowed_request_origins = [/(http|https):\/\/.*alegreme.*/]
	# config.action_cable.disable_request_forgery_protection = true # only if necessary

	# Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
	config.force_ssl = true

	# Use the lowest log level to ensure availability of diagnostic information
	# when problems arise.
	config.log_level = :debug

	# Prepend all log lines with the following tags.
	config.log_tags = [:request_id]

	# Use a different cache store in production.
	# config.cache_store = :dalli_store, 'memcached', {:pool_size => 5}
	config.cache_store = :redis_cache_store, {url:             ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" },
	                                          reconnect_attempts: 1, # Defaults to 0
	                                          error_handler: -> (method:, returning:, exception:) {
		                                          Raven.capture_exception exception,
		                                                                  level: 'warning',
		                                                                  tags:  {
				                                                                  method:    method,
				                                                                  returning: returning
		                                                                  }
	                                          }
	}
	config.session_store :cache_store,
	                     key:          "_session",
	                     compress:     true,
	                     pool_size:    5,
	                     expire_after: 3.months

	# Use a real queuing backend for Active Job (and separate queues per environment)
	config.active_job.queue_adapter = :sidekiq
	# config.active_job.queue_name_prefix = "app_#{Rails.env}"

	config.action_mailer.delivery_method     = :smtp
	config.action_mailer.default_url_options = {host: "https://alegreme.com"}
	config.action_mailer.asset_host          = "https://alegreme.com"
	config.action_mailer.perform_caching     = false

	# Ignore bad email addresses and do not raise email delivery errors.
	# Set this to true and configure the email server for immediate delivery to raise delivery errors.
	# config.action_mailer.raise_delivery_errors = false

	# Enable locale fallbacks for I18n (makes lookups for any locale fall back to
	# the I18n.default_locale when a translation cannot be found).
	config.i18n.fallbacks = true

	# Send deprecation notices to registered listeners.
	config.active_support.deprecation = :notify

	# Log disallowed deprecations.
	config.active_support.disallowed_deprecation = :log
	# Tell Active Support which deprecation messages to disallow.
	config.active_support.disallowed_deprecation_warnings = []

	# Use default logging formatter so that PID and timestamp are not suppressed.
	config.log_formatter = ::Logger::Formatter.new

	# Use a different logger for distributed setups.
	# require 'syslog/logger'
	# config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new 'app-name')

	if ENV["RAILS_LOG_TO_STDOUT"].present?
		logger           = ActiveSupport::Logger.new(STDOUT)
		logger.formatter = config.log_formatter
		config.logger    = ActiveSupport::TaggedLogging.new(logger)
	end

	# Do not dump schema after migrations.
	config.active_record.dump_schema_after_migration = false

	config.action_controller.default_url_options = {
			host: ENV['HTTP_HOST'] || 'localhost'
	}


end
