# frozen_string_literal: true

class ApplicationReflex < StimulusReflex::Reflex
	require 'sentry-ruby'
	# Put application wide Reflex behavior in this file.
	delegate :current_user, to: :connection

	rescue_from StandardError do |exception|
		Sentry.capture_exception exception, level: 'warning'
	end
	#
	# Example:
	#
	#   # If your ActionCable connection is: `identified_by :current_user`
	#   delegate :current_user, to: :connection
	#
	# Learn more at: https://docs.stimulusreflex.com
	#
end
