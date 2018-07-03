# frozen_string_literal: true

FactoryBot.define do
  factory :tool do
    name 'MyString'
    url 'MyString'
    photo { Rack::Test::UploadedFile.new(File.open(Rails.root.join('spec', 'fixtures', 'images', 'image.jpg'))) }
    description 'MyText'
  end
end
