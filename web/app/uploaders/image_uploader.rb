require 'image_processing/mini_magick'

class ImageUploader < Shrine
  plugin :processing
  plugin :versions
  plugin :delete_raw

  plugin :add_metadata
  plugin :color

  add_metadata :dominant_color do |io, context|
    dominant_color(io.path)
  end

  add_metadata :palette_color do |io, context|
    palette_color(io.path, 3)
  end

  # def generate_location(io, context)
  #   filename = context[:metadata]["filename"]

  #   "#{filename}_#{super}"
  # end

  process(:store) do |io, context|
    # image_optim = ImageOptim.new(pngout: false, svgo: false)
    # image_optim.optimize_image!(io.download)
    # io.open

    versions = { 'original': io }

    io.download do |original|
      pipeline = ImageProcessing::MiniMagick.source(original)

      versions['feed'] = pipeline.resize_to_fill!(340, 190)
      # versions['feed-mobile'] = pipeline.resize_to_fill!(183, 103)
      # versions['single'] = pipeline.resize_to_fill!(600, 338)
      # versions['single-mobile'] = pipeline.resize_to_fill!(414, 232)
      # versions['list-mobile'] = pipeline.resize_to_fill!(116, 66)
    end

     versions
  end
end
