module ApplicationHelper
	def mobile_device?
		if session[:mobile_param]
				session[:mobile_param] == "1"
		else
				request.user_agent =~ /Mobile|webOS/
		end
	end

	def responsive_image_tag(image, opts = {})

    content_tag(:picture) do
			concat content_tag(:source, nil, media: "(max-width: 480px)", srcset: "#{image_url(image + '@2x')} 2x", alt: opts[:alt], title: opts[:title])
			concat content_tag(:source, nil, media: "(max-width: 480px)", srcset: "#{image_url(image + '@1.5x')} 1.5x", alt: opts[:alt], title: opts[:title])
      concat image_tag image, alt: opts[:alt], title: opts[:title], class: opts[:class]
    end
  end
end
