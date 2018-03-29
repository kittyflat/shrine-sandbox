class CoverPhotoUploader < ImageUploader
  process(:store) do |io, context|
    original = io.download

    resized = ImageProcessing::MiniMagick
      .source(original)
      .resize_to_fill!(1200, 300)

    original.close!

    resized
  end
end
