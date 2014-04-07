# encoding: utf-8

class PostAttachmentUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  version :figure do
    process :resize_to_fit => [400, 400]
  end

end
