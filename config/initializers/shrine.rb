require "shrine"
require "shrine/storage/file_system"

# File system
# Shrine.storages = {
#   cache: Shrine::Storage::FileSystem.new("public", prefix: "uploads/cache"), # temporary
#   store: Shrine::Storage::FileSystem.new("public", prefix: "uploads/store"), # permanent
# }

require "shrine/storage/s3"

s3_options = {
  access_key_id:     Rails.application.secrets.aws_access_key_id,
  secret_access_key: Rails.application.secrets.aws_secret_access_key,
  bucket:            "shrine-sandbox-development",
  region:            "us-west-1",
}

Shrine.storages = {
  cache: Shrine::Storage::S3.new(prefix: "cache", **s3_options),
  store: Shrine::Storage::S3.new(prefix: "store", **s3_options),
}

# Plugins
Shrine.plugin :activerecord # or :sequel
Shrine.plugin :cached_attachment_data # for forms
# Shrine.plugin :rack_file # for non-Rails apps
Shrine.plugin :determine_mime_type
Shrine.plugin :logging # , logger: Rails.logger
# Shrine.plugin :remove_attachment

# MiniMagick logging
# https://github.com/minimagick/minimagick#logging
MiniMagick.logger.level = Logger::DEBUG
MiniMagick.logger = Rails.logger
