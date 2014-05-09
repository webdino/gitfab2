module UploadFileHelper
  def self.upload_file
    Rack::Test::UploadedFile.new File.open(File.join Rails.root, "/spec/assets/images/image.jpg")
  end
end
