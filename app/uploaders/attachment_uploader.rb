# encoding: utf-8

class AttachmentUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include CarrierWave::Backgrounder::Delay

  version :small, if: :is_image?
  version :thumb, if: :is_stl?
  version :tmp, if: :is_stl?

  storage :file
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  version :small do
    process resize_to_fit: [400, 400]
  end

  version :tmp do
    after :store, :generate_png
    def full_filename(for_file)
      'tmp_' + for_file.slice(0..-4) << 'png'
    end
  end

  version :thumb do
    after :store, :generate_gif
    def full_filename(for_file)
      'thumb_' + for_file.slice(0..-4) << 'gif'
    end
  end

  private

  def is_image?(file)
    MiniMagick::Image.open(file.path)
    return true
  rescue => _e
    return false
  end

  def is_stl?(file)
    file.filename[-4..-1] == '.stl'
  end

  def generate_png
    stl = Stl2gif::Stl.new self.file.path
    tmp_png_file = stl.to_png self.file.original_filename
    image = MiniMagick::Image.read tmp_png_file
    filepath = self.file.file
    image.write filepath
  end

  def generate_gif
    stl = Stl2gif::Stl.new self.file.path
    stl.generate_frames
    tmp_gif_file = stl.to_gif self.file.original_filename
    image = MiniMagick::Image.read tmp_gif_file
    filepath = self.file.file
    image.write filepath
  end
end
