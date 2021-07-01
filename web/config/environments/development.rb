require "active_support/core_ext/integer/time"

require 'socket'
require 'ipaddr'

Rails.application.configure do
	# Settings specified here will take precedence over those in config/application.rb.

	# In the development environment your application's code is reloaded on
	# every request. This slows down response time but is perfect for development
	# since you don't have to restart the web server when you make code changes.
	config.cache_classes = false

	config.web_console.allowed_ips = ['10.0.0.0/8', '172.16.0.0/12', '192.168.0.0/16', '172.16.0.0/12']

	# Do not eager load code on boot.
	config.eager_load = false

	# Show full error reports.
	config.consider_all_requests_local = true

	# Enable/disable caching. By default caching is disabled.
	# Run rails dev:cache to toggle caching.
	if Rails.root.join("tmp", "caching-dev.txt").exist?
		config.action_controller.perform_caching               = true
		config.action_controller.enable_fragment_cache_logging = true
		# config.cache_store = :dalli_store, 'memcached', { :pool_size => 2 }
		config.cache_store = :redis_cache_store, { url:                ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" },
																							 reconnect_attempts: 1 }
		# config.public_file_server.enabled = true
		# config.public_file_server.headers = {
		#   "Cache-Control" => "public, max-age=#{2.days.to_i}",
		# }
	else
		config.action_controller.perform_caching = false
		config.cache_store                       = :null_store
	end

	config.session_store :cache_store

	# config.active_job.queue_adapter = :sidekiq

	# Store uploaded files on the local file system (see config/storage.yml for options)
	config.active_storage.service = :local

	# Don't care if the mailer can't send.
	config.action_mailer.raise_delivery_errors = false

	config.action_mailer.perform_caching = false

 	config.hosts << "app"
	config.hosts << "flutter-724980c0dcd02d8fda535068339fb6fbebf437d6a9.sa.ngrok.io"

	config.action_mailer.default_url_options = { host: "localhost", port: 3000 }
	config.action_mailer.delivery_method     = :smtp
	config.action_mailer.perform_deliveries  = false

	config.webpacker.check_yarn_integrity = false

	# Print deprecation notices to the Rails logger.
	config.active_support.deprecation = :log

	# Logger file size
	# config.logger = ActiveSupport::Logger.new(config.paths['log'].first, 1, 2.megabytes)

	# :debug, :info, :warn, :error, :fatal, :unknown
	config.log_level = :debug

	# Raise an error on page load if there are pending migrations.
	config.active_record.migration_error = :page_load

	# Highlight code that triggered database queries in logs.
	config.active_record.verbose_query_logs = true

	# Debug mode disables concatenation and preprocessing of assets.
	# This option may cause significant delays in view rendering with a large
	# number of complex assets.
	config.assets.debug = true

	# Suppress logger output for asset requests.
	config.assets.quiet         = true
	config.assets.js_compressor = Uglifier.new(harmony: true)

	# Raises error for missing translations
	# config.action_view.raise_on_missing_translations = true

	# Use an evented file watcher to asynchronously detect changes in source code,
	# routes, locales, etc. This feature depends on the listen gem.
	config.file_watcher = ActiveSupport::EventedFileUpdateChecker

	# config.after_initialize do
	# 	Bullet.enable = true
	# 	# Bullet.alert = true
	# 	Bullet.bullet_logger = true
	# 	Bullet.console = true
	# 	Bullet.rails_logger = true
	# end
end
