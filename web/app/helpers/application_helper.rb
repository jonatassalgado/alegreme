module ApplicationHelper
	include Pagy::Frontend

	def class_string(css_map)
		css_map.find_all(&:last).map(&:first).join(" ")
	end

	def link_to_topic topic
		if topic.class.name == 'Place'
			place_path(topic)
		elsif topic.class.name == 'Organizer'
			organizer_path(topic)
		end
	end

	def to_hashtag sentence
		"##{sentence.gsub(/ /, '')}"
	end

	def mobile_device?
		if session[:mobile_param]
			session[:mobile_param] == "1"
		else
			request.user_agent =~ /Mobile|webOS/
		end
	end

	def responsive_image_tag(image, opts = {})
		opts = {only: {'1.5x' => true, '2x' => true}}.merge(opts)

		content_tag(:picture, alt: opts[:alt]) do
			concat content_tag(:source, nil, media: "(max-width: 480px)", srcset: "#{image_url(image + '@2x')} 2x", alt: opts[:alt], title: opts[:title]) if opts.dig(:only, '2x')
			concat content_tag(:source, nil, media: "(max-width: 480px)", srcset: "#{image_url(image + '@1.5x')} 1.5x", alt: opts[:alt], title: opts[:title]) if opts.dig(:only, '1.5x')
			concat image_tag image, alt: opts[:alt], title: opts[:title], class: opts[:class], loading: 'lazy'
		end
	end


	def full_image_url url
		"https://alegreme.com" + url
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
				nil
			else
				return I18n.l(@current_date, format: :short)
			end
		end
	end

end
