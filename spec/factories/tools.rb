# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tool do
    name "MyString"
    url "MyString"
    photo Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/assets/images/image.jpg')))
    description "MyText"
    recipe nil
  end
end
