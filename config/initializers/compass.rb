Gitfab2::Application.configure do
  sprite_dir = File.join(config.compass.generated_images_dir, 'generated')
  config.compass.generated_images_dir = sprite_dir
  config.assets.paths << sprite_dir
end
