# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { "user-#{SecureRandom.hex 10}" }
    email { "#{SecureRandom.uuid}@example.com" }
  end

  factory :administrator, parent: :user do
    authority 'admin'
  end
end
