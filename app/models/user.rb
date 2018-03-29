class User < ApplicationRecord
  include AvatarUploader::Attachment.new(:avatar)
  include CoverPhotoUploader::Attachment.new(:cover_photo)
end
