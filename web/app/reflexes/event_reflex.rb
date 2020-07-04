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
	def save(args)
		current_user.public_send("taste_#{args[:resource]}_#{args[:action]}", args[:id].to_i)
	end

	def update_collection(args = {})

		filter_type  = args.dig(:filter, :type)
		filter_value = args.dig(:filter, :value)
		limit        = args[:limit]

		case filter_type
		when 'days'
			session[:days] = filter_value.any? ? filter_value.map { |day| day.to_date.yday } : []
		when 'categories'
			session[:categories] = filter_value.any? ? filter_value : []
		end

		if limit.blank? && filter_value.empty?
			session[:limit] = 16
		else
			session[:limit] = limit
		end
	end

	def show_similar(args = {})
		session[:show_similar_to] |= [args[:show_similar_to].to_i]
		session[:in_this_section] = args[:in_this_section]
	end
end
