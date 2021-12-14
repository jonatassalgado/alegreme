# Sentry
if Rails.env.production? || Rails.env.development?
	Sentry.init do |config|
		config.dsn                = Rails.application.credentials[Rails.env.to_sym][:sentry_dsn]
		config.traces_sample_rate = 0.2
		# config.excluded_exceptions = []
		filter = ActionDispatch::Http::ParameterFilter.new(Rails.application.config.filter_parameters)
		config.before_send = lambda do |event, hint|
			filter.filter(event.to_hash)
		end
	end
end
