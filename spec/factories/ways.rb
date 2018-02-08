# frozen_string_literal: true

FactoryGirl.define do
  factory :way do
    name 'MyString'
    description 'MyText'
    photo Rack::Test::UploadedFile.new(File.open(Rails.root.join('spec', 'assets', 'images', 'image.jpg')))
  end
end
