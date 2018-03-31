class ImageUploader < Shrine
  plugin :store_dimensions
  plugin :processing
  plugin :delete_raw # delete processed files after uploading, unless it's an UploadedFile
end
