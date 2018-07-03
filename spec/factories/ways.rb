# frozen_string_literal: true

FactoryBot.define do
  factory :way do
    name 'MyString'
    description 'MyText'
    photo { Rack::Test::UploadedFile.new(File.open(Rails.root.join('spec', 'fixtures', 'images', 'image.jpg'))) }
  end
end
