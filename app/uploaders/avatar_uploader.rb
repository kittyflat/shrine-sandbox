class AvatarUploader < ImageUploader
  plugin :versions # enable Shrine to handle a hash of files

  process(:store) do |io, context|
    original = io.download
    pipeline = ImageProcessing::MiniMagick.source(original)

    large = pipeline.resize_to_fill!(300, 300)
    small = pipeline.resize_to_fill!(100, 100)

    original.close!
    { original: io, large: large, small: small }
  end
end
