module AssetsHelper
	def responsive_image_tag(image, opts = {})
		opts = { only: { '1.5x' => true, '2x' => true }, format: :jpg }.merge(opts)

		content_tag(:picture, alt: opts[:alt]) do
			concat content_tag(:source, nil, media: "(max-width: 480px)", srcset: "#{image_pack_tag("#{image}@2x.#{opts[:format]}")} 2x", alt: opts[:alt], title: opts[:title]) if opts.dig(:only, '2x')
			concat content_tag(:source, nil, media: "(max-width: 480px)", srcset: "#{image_pack_tag("#{image}@1.5x.#{opts[:format]}")} 1.5x", alt: opts[:alt], title: opts[:title]) if opts.dig(:only, '1.5x')
			concat image_pack_tag "#{image}.#{opts[:format]}", alt: opts[:alt], title: opts[:title], class: opts[:class], loading: 'lazy'
		end
	end

	def webp_image_tag(image, fallback, opts = { alt: nil, title: nil, lazy: nil })
		content_tag(:picture) do
			concat content_tag(:source, nil, srcset: image_path(image)) if image
			concat content_tag(:source, nil, srcset: image_path(fallback)) if fallback
			concat image_tag fallback, alt: opts[:alt], title: opts[:title], loading: opts[:lazy], class: opts[:class]
		end
	end

	def inline_assets name
		File.read(File.join(Rails.root, 'public', Webpacker.manifest.lookup(name))).html_safe
	end

	def full_image_url url
		"https://alegreme.com" + url
	end
end