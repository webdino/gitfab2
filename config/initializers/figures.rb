Dir.glob(File.expand_path("#{Rails.root}/app/models/figure/*.rb", __FILE__)).each do |file|
  require file
end
