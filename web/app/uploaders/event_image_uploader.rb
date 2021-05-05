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
        original: pipeline.resize_to_fill!(850, 475),
        feed: pipeline.resize_to_fill!(340, 190)
      }
    end
  end
end
