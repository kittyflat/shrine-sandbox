class LookPhotoUploader < ImageUploader
  plugin :versions # enable Shrine to handle a hash of files

  Attacher.validate do
    super()
    # TODO
    # look photo validations
  end

  process(:store) do |io, context|
    original = io.download

    sizes = {
      large: [960, 960],
      medium: [560, 560],
      small: [250, 250],
      thumb: [150, 150],
      list: [390, nil]
    }

    versions = {
      original: io
    }

    # image = MiniMagick::Image.new(original)
    # image.combine_options do |

    sizes.each do |name, dimensions|
      width = dimensions.first
      height = dimensions.last

      jpeg_size_hint = ""
      jpeg_size_hint += "#{width * 2}" if width
      jpeg_size_hint += "x"
      jpeg_size_hint += "#{height * 2}" if height

      pipeline = ImageProcessing::MiniMagick
        .source(original)
        .loader(strip: true, define: { jpeg: { size: jpeg_size_hint }}) # .loader(strip: true, define: { jpeg: { size: "#{width * 2}x#{height * 2}" }})
        .saver(quality: 90)
        .convert("jpg")
        .colorspace("RGB")

        # sharpen after resize?
        # there isn't a clear best setting
        # best suggestion is to try many different photos
        # http://www.imagemagick.org/Usage/resize/#resize_unsharp

      # large = pipeline.resize_to_limit(960, 960).colorspace("sRGB").call
      # medium = pipeline.resize_to_limit(560, 560).colorspace("sRGB").call
      # small = pipeline.resize_to_limit(250, 250).colorspace("sRGB").call
      # thumb = pipeline.resize_to_limit(150, 150).colorspace("sRGB").call
      # list = pipeline.resize_to_limit(390, nil).colorspace("sRGB").call
      # versions = { original: io, large: large, medium: medium, small: small, thumb: thumb, list: list }
      versions[name] = pipeline.resize_to_limit(width, height).colorspace("sRGB").call
    end


    original.close!

    # { original: io, large: large, small: small }
    versions
  end
end
