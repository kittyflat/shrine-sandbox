class Look < ApplicationRecord
  include LookPhotoUploader::Attachment.new(:photo)
  validates_presence_of :photo
  belongs_to :user
end
