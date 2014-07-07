# encoding: utf-8

class AttachmentUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  version :small, :if => :is_image?

  storage :file
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  version :small do
    process :resize_to_fit => [400, 400]
  end

  def is_image? file
    begin
      MiniMagick::Image.open(file.path)
      return true
    rescue => e
      return false
    end
  end

end
