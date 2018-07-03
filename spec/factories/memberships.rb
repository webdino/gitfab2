# frozen_string_literal: true

FactoryBot.define do
  factory :membership do
    user
    group
    role 'MyString'
  end
end
