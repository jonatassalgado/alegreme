require 'image_processing/mini_magick'

class MovieImageUploader < Shrine
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
				# large: pipeline.resize_to_fill!(315, 480),
				medium: pipeline.resize_to_fill!(126, 192),
				small:  pipeline.resize_to_fill!(62, 95)
			}
		end
	end

end
