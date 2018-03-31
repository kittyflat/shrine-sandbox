class User < ApplicationRecord
  include AvatarUploader::Attachment.new(:avatar)
  include CoverPhotoUploader::Attachment.new(:cover_photo)

  validates_presence_of :avatar
  # validates_presence_of :cover_photo
end
