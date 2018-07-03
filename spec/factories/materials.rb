# frozen_string_literal: true

FactoryBot.define do
  factory :material do
    name 'MyString'
    size 'MyString'
    url 'MyString'
    description 'MyText'
    photo { Rack::Test::UploadedFile.new(File.open(Rails.root.join('spec', 'fixtures', 'images', 'image.jpg'))) }
  end
end
