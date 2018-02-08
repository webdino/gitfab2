# frozen_string_literal: true

FactoryGirl.define do
  factory :group do
    name { "group#{SecureRandom.hex 10}" }
  end
end
