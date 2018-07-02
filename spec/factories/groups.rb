# frozen_string_literal: true

FactoryBot.define do
  factory :group do
    name { "group#{SecureRandom.hex 10}" }
  end
end
