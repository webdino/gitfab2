class FigureUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file

  process :fix_exif_rotation

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  version :small do
    process resize_to_fit: [400, 400]
    process remove_animation: true
  end

  version :medium do
    process resize_to_fit: [820, 10_000]
    process :remove_animation
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def default_url
    'fallback/blank.png'
  end

  def play_btn_path
    Rails.root + 'app/assets/images/play.png'
  end

  def remove_animation(is_using_play_btn = false)
    manipulate! do |img|
      if img.mime_type.match /gif/
        img.collapse!
        img = add_play_btn img if is_using_play_btn
      end
      img
    end
  end

  def add_play_btn(src_img)
    overlay_file = File.open(play_btn_path).read
    overlay_img =  MiniMagick::Image.read(overlay_file)
    x = ((src_img['width'] - overlay_img['width']) / 2).floor
    y = ((src_img['height'] - overlay_img['height']) / 2).floor
    img = src_img.composite overlay_img, 'png' do |c|
      c.channel 'A'
      c.alpha 'Activate'
      c.compose 'Over'
      c.geometry "+#{x}+#{y}"
    end
    img
  end

  def fix_exif_rotation
    manipulate! do |img|
      img.tap(&:auto_orient)
    end
  end
end
