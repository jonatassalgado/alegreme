module MetaTagsHelper
	def meta_title
		content_for?(:meta_title) ? content_for(:meta_title) : DEFAULT_META["meta_title"]
	end

	def meta_description
		content_for?(:meta_description) ? content_for(:meta_description) : DEFAULT_META["meta_description"]
	end

	def meta_image
		meta_image = (content_for?(:meta_image) ? content_for(:meta_image) : DEFAULT_META["meta_image"])
		# ajoutez la ligne ci-dessous pour que le helper fonctionne indifféremment
		# avec une image dans vos assets ou une url absolue
		meta_image.starts_with?("http") ? meta_image : image_url(meta_image)
	end

	def canonical_url
		if content_for?(:canonical_url)
			tag(:link, rel: :canonical, href: content_for(:canonical_url))
		end
	end

	def amp_url
		if content_for?(:amp_url)
			tag(:link, rel: :amphtml, href: content_for(:amp_url))
		end
	end
end