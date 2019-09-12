module ApplicationHelper
	include Pagy::Frontend

	def mobile_device?
		if session[:mobile_param]
			session[:mobile_param] == "1"
		else
			request.user_agent =~ /Mobile|webOS/
		end
	end

	def responsive_image_tag(image, opts = {})
		opts = {only: {'1.5x' => true, '2x' => true}}.merge(opts)

		content_tag(:picture) do
			concat content_tag(:source, nil, media: "(max-width: 480px)", srcset: "#{image_url(image + '@2x')} 2x", alt: opts[:alt], title: opts[:title]) if opts.dig(:only, '2x')
			concat content_tag(:source, nil, media: "(max-width: 480px)", srcset: "#{image_url(image + '@1.5x')} 1.5x", alt: opts[:alt], title: opts[:title]) if opts.dig(:only, '1.5x')
			concat image_tag image, alt: opts[:alt], title: opts[:title], class: opts[:class], loading: 'lazy'
		end
	end


	def full_image_url url
		"https://alegreme.com" + url
	end
end
