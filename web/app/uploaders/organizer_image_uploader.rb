require 'image_processing/mini_magick'

class OrganizerImageUploader < Shrine
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

			{
				sm: pipeline.resize_to_fill!(50, 50)
			}
		end
	end

end
