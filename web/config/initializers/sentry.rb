
# Sentry
if Rails.env.production? 
    Raven.configure do |config|
        config.dsn = Rails.application.credentials[Rails.env.to_sym][:sentry_dsn]
        # config.excluded_exceptions = []
        config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
    end
end
