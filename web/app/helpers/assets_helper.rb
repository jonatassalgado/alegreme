module AssetsHelper
	def inline_js(path)
		"<script>#{Rails.application.assets_manifest.find_sources(path).first.to_s}</script>".html_safe
	end

	def inline_css(path)
		"<style>#{Rails.application.assets_manifest.find_sources(path).first.to_s}</style>".html_safe
	end
end