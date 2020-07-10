require_relative 'boot'

require 'rails/all'


# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module App
	class Application < Rails::Application
		# Initialize configuration defaults for originally generated Rails version.
		config.load_defaults 6.0
		config.i18n.default_locale = 'pt-BR'
		config.encoding            = 'utf-8'
		config.time_zone           = 'Brasilia'
		config.autoload_paths      += %W(#{config.root}/lib #{config.root}/services #{config.root}/decorators #{config.root}/queries)

		config.assets.configure do |env|
			env.register_mime_type('application/manifest+json', extensions: ['.webmanifest'])
		end

		config.filter_parameters << :password

		config.middleware.use Rack::Attack
		config.middleware.insert_after ActionDispatch::Static, Rack::Deflater

		# Settings in config/environments/* take precedence over those specified here.
		# Application configuration can go into files in config/initializers
		# -- all .rb files in that directory are automatically loaded after loading
		# the framework and any gems in your application.

	end
end
