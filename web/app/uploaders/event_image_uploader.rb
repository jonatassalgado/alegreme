require 'image_processing/mini_magick'

class EventImageUploader < Shrine
	plugin :processing
	plugin :versions
	plugin :delete_raw
	plugin :pretty_location

	plugin :add_metadata
	plugin :color

	add_metadata :dominant_color do |io, context|
		dominant_color(io.path)
	end

	add_metadata :palette_color do |io, context|
		palette_color(io.path, 3)
	end

	process(:store) do |io, context|
		io.download do |original|
			pipeline = ImageProcessing::MiniMagick.source(original)
																						.convert('jpeg')
																						.saver(quality: 95)

			{
				original: pipeline.resize_to_fill!(625, 352, sharpen: { radius: 0.25, sigma: 0.25 }),
				feed:     pipeline.resize_to_fill!(200, 113, sharpen: { radius: 0.25, sigma: 0.25 })
			}
		end
	end
end
