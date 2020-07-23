# frozen_string_literal: true

class EventReflex < ApplicationReflex
	# Add Reflex methods in this file.
	#
	# All Reflex instances expose the following properties:
	#
	#   - connection - the ActionCable connection
	#   - channel - the ActionCable channel
	#   - request - an ActionDispatch::Request proxy for the socket connection
	#   - session - the ActionDispatch::Session store for the current visitor
	#   - url - the URL of the page that triggered the reflex
	#   - element - a Hash like object that represents the HTML element that triggered the reflex
	#   - params - parameters from the element's closest form (if any)
	#
	# Example:
	#
	#   def example(argument=true)
	#     # Your logic here...
	#     # Any declared instance variables will be made available to the Rails controller and view.
	#   end
	#
	# Learn more at: https://docs.stimulusreflex.com
	def save
		current_user.public_send("taste_#{element['data-save-button-resource-name']}_#{element['data-save-button-action']}", element['data-save-button-resource-id'].to_i)
	end

	def update_collection(args = {})
		session[:stimulus][:days]       = args.dig(:filters, :days) || []
		session[:stimulus][:categories] = args.dig(:filters, :categories) || []
		session[:stimulus][:limit]      = args.dig(:limit) || 16
	end

	def show_similar(args = {})
		session[:stimulus][:show_similar_to] |= [args[:show_similar_to].to_i]
		session[:stimulus][:in_this_section] = args[:in_this_section]
	end
end
