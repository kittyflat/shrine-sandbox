require "shrine"
require "shrine/storage/file_system"

# File system
# Shrine.storages = {
#   cache: Shrine::Storage::FileSystem.new("public", prefix: "uploads/cache"), # temporary
#   store: Shrine::Storage::FileSystem.new("public", prefix: "uploads/store"), # permanent
# }

# require "shrine/storage/s3"
# 
# s3_options = {
#   access_key_id:     Rails.application.secrets.aws_access_key_id,
#   secret_access_key: Rails.application.secrets.aws_secret_access_key,
#   bucket:            "shrine-sandbox-development",
#   region:            "us-west-1",
# }
# 
# Shrine.storages = {
#   cache: Shrine::Storage::S3.new(prefix: "cache", **s3_options),
#   store: Shrine::Storage::S3.new(prefix: "store", **s3_options),
# }

# require_dependency "#{Rails.root}/app/models/shrine/storage/b2"
b2_options = {
  account_id: Rails.application.secrets.b2_account_id,
  application_key: Rails.application.secrets.b2_application_key,
  bucket_name: "shrine-sandbox-development",
  bucket_id: "b02bd4dd6fabb6ad602a001a"
}

Shrine.storages = {
  # Use B2 for cache
  # Warning: upload from B2 cache to B2 store doesn't work
  # Due to lack of copy api, need to download from B2 cache and re-upload to B2 store
  # cache: Shrine::Storage::B2.new(prefix: "cache", **b2_options),

  # Use FileSystem for cache
  cache: Shrine::Storage::FileSystem.new("public", prefix: "uploads/cache"), # temporary
  store: Shrine::Storage::B2.new(prefix: "store", **b2_options)
}

# Plugins
Shrine.plugin :activerecord # or :sequel
Shrine.plugin :cached_attachment_data # for forms
# Shrine.plugin :rack_file # for non-Rails apps
Shrine.plugin :determine_mime_type
Shrine.plugin :logging # , logger: Rails.logger
Shrine.plugin :backgrounding
# Shrine.plugin :remove_attachment

# make all uploaders use background jobs
Shrine::Attacher.promote { |data| PromoteJobWorker.perform_async(data) }
Shrine::Attacher.delete { |data| DeleteJobWorker.perform_async(data) }

# MiniMagick logging
# https://github.com/minimagick/minimagick#logging
MiniMagick.logger.level = Logger::DEBUG
MiniMagick.logger = Rails.logger
