class AvatarUploader < ImageUploader
  plugin :versions # enable Shrine to handle a hash of files

  process(:store) do |io, context|
    original = io.download

    sizes = {
      large: [300, 300],
      small: [100, 100]
    }

    versions = {
      original: io
    }

    # image = MiniMagick::Image.new(original)
    # image.combine_options do |

    sizes.each do |name, dimensions|
      width = dimensions.first
      height = dimensions.last

      pipeline = ImageProcessing::MiniMagick
        .source(original)
        .loader(strip: true, define: { jpeg: { size: "#{width * 2}x#{height * 2}" }})
        .saver(quality: 90)
        .convert("jpg")
        .colorspace("RGB")

        # sharpen after resize?
        # there isn't a clear best setting
        # best suggestion is to try many different photos
        # http://www.imagemagick.org/Usage/resize/#resize_unsharp

      versions[name] = pipeline.resize_to_fill(width, height).colorspace("sRGB").call
    end


    original.close!

    # { original: io, large: large, small: small }
    versions
  end
end
