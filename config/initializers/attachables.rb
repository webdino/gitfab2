Dir.glob(File.expand_path("#{Rails.root}/app/models/attachment/*.rb", __FILE__)).each do |file|
  require file
end

