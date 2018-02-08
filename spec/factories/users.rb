# frozen_string_literal: true

FactoryGirl.define do
  factory :user do
    name { "user-#{SecureRandom.hex 10}" }
    email { "#{SecureRandom.uuid}@example.com" }
    password 'password'
  end

  factory :administrator, parent: :user do
    authority 'admin'
  end
end
