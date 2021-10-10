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

			{
				original: pipeline.resize_to_fill(625, 352).convert('jpg').saver!(quality: 70),
				medium:   pipeline.resize_to_fill(412, 240).convert('webp').saver!(quality: 50),
				feed:     pipeline.resize_to_fill(200, 113).convert('jpg').saver!(quality: 70)
			}
		end
	end
end
