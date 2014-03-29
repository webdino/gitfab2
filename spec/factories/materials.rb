# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :material do
    name "MyString"
    size "MyString"
    url "MyString"
    description "MyText"
    photo Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/assets/images/image.jpg')))
  end
end
