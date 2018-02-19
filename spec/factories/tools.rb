# frozen_string_literal: true

FactoryGirl.define do
  factory :tool do
    name 'MyString'
    url 'MyString'
    photo Rack::Test::UploadedFile.new(File.open(Rails.root.join('spec', 'assets', 'images', 'image.jpg')))
    description 'MyText'
  end
end
