module ApplicationHelper
	include Pagy::Frontend

	def movies_active_count
		Rails.cache.fetch('movies_active_size', expires_in: 12.hours) { Movie.active.exists? }
	end

	def class_string(css_map)
		css_map.find_all(&:last).map(&:first).join(" ")
	end

	def class_names(*args)
		safe_join(build_tag_values(*args), " ")
	end

	def build_tag_values(*args)
		tag_values = []

		args.each do |tag_value|
			case tag_value
			when Hash
				tag_value.each do |key, val|
					tag_values << key if val
				end
			when Array
				tag_values << build_tag_values(*tag_value).presence
			else
				tag_values << tag_value.to_s if tag_value.present?
			end
		end

		tag_values.compact.flatten
	end

	module_function :build_tag_values

	def link_to_follow followable
		if followable.class.name == 'Place'
			place_path(followable)
		elsif followable.class.name == 'Organizer'
			organizer_path(followable)
		end
	end

	def to_hashtag sentence
		"##{sentence.gsub(/ /, '')}"
	end

	def browser
		Browser.new(request.user_agent)
	end

	def modern_browser?
		[
				browser.chrome?(">= 65"),
				browser.safari?(">= 10"),
				browser.firefox?(">= 52"),
				browser.edge?(">= 15"),
				browser.opera?(">= 50")
		].any?
	end

	def mobile_device?
		if session[:mobile_param]
			session[:mobile_param] == "1"
		else
			browser.device.mobile?
		end
	end

	def pwa?
		params[:pwa]
	end


	def google_maps_url address
		"https://www.google.com/maps/search/?api=1&query=#{address}"
	end

	def day_of_week(day, opts = {})
		return if day.blank?

		@today        = Date.current
		@current_date = day.to_date
		@difference   = @current_date.mjd - DateTime.now.mjd

		case @difference
		when 0
			return 'hoje'
		when 1
			return 'amanhã'
		when 2..6
			return case @current_date.wday
			       when 0
				       'domingo'
			       when 1
				       'segunda'
			       when 2
				       'terça'
			       when 3
				       'quarta'
			       when 4
				       'quinta'
			       when 5
				       'sexta'
			       when 6
				       'sábado'
			       end
		when 7..14
			# if opts[:active_range]
			# 	return add_to_response('próximos 30 dias', range: true, order: 8)
			# else
			return "#{I18n.l(@current_date, format: :week)} · #{I18n.l(@current_date, format: :short)}"
			# end
		when 14..90
			if opts[:active_range]
				return 'próximos 90 dias'
			else
				return "#{I18n.l(@current_date, format: :short)} · #{I18n.l(@current_date, format: :week)}"
			end
		else
			if opts[:active_range]
				return "#{I18n.l(@current_date, format: :short)} · #{I18n.l(@current_date, format: :week)}"
			else
				return I18n.l(@current_date, format: :short)
			end
		end
	end

end
