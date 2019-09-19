ActionMailer::Base.smtp_settings = {
		domain:         'alegreme.com',
		address:        "smtp.sendgrid.net",
		port:           587,
		authentication: :plain,
		user_name:      'apikey',
		password:       Rails.application.credentials[Rails.env.to_sym][:sendgrid][:api_key]
}