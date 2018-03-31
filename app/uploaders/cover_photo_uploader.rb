class CoverPhotoUploader < ImageUploader
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
