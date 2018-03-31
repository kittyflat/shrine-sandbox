class ImageUploader < Shrine
  plugin :store_dimensions
  plugin :processing
  plugin :delete_raw # delete processed files after uploading, unless it's an UploadedFile
  plugin :validation_helpers
  plugin :remove_invalid

  Attacher.validate do
    validate_mime_type_inclusion %w[image/jpeg image/jpg image/png image/pjpeg]
  end
end
