class ImageUploader < Shrine

  ALLOWED_EXTENSIONS = %w[jpg jpeg png]
  ALLOWED_TYPES = %w[image/jpeg image/jpg image/png image/pjpeg]
  MAX_SIZE = 10*1024*1024 # 10 MB
  MIN_SIZE = 10*1024 # 10 KB
  MAX_DIMENSIONS = 10_000

  plugin :store_dimensions
  plugin :processing
  plugin :delete_raw # delete processed files after uploading, unless it's an UploadedFile
  plugin :delete_promoted # delete cached files once they're uploaded to store
  plugin :validation_helpers
  plugin :remove_invalid

  def generate_location(io, context)
    record = context[:record].class.name.downcase if context[:record]
    attachment_name = context[:name].to_s # name of the attachment attribute on the model
    style = context[:version].to_s if context[:version]
    name = super # the default unique identifier
    [record, attachment_name, style, name].compact.join("/")
  end

  Attacher.validate do
    validate_max_size MAX_SIZE
    validate_min_size MIN_SIZE
    validate_extension_inclusion ALLOWED_EXTENSIONS
    if validate_mime_type_inclusion ALLOWED_TYPES
      validate_max_width MAX_DIMENSIONS
      validate_max_height MAX_DIMENSIONS
    end
  end
end
