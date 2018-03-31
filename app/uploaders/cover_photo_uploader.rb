class CoverPhotoUploader < ImageUploader

  Attacher.validate do
    super()
    validate_min_width 980
    validate_min_height 250
  end

  process(:store) do |io, context|
    original = io.download

    resized = ImageProcessing::MiniMagick
      .source(original)
      .loader(strip: true)
      .saver(quality: 90)
      .convert("jpg")
      .resize_to_fill!(1200, 300)

    original.close!

    resized
  end
end
