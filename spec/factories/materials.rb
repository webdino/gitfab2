# frozen_string_literal: true

FactoryGirl.define do
  factory :material do
    name 'MyString'
    size 'MyString'
    url 'MyString'
    description 'MyText'
    photo Rack::Test::UploadedFile.new(File.open(Rails.root.join('spec', 'assets', 'images', 'image.jpg')))
  end
end
