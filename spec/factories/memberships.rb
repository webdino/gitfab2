# frozen_string_literal: true

FactoryBot.define do
  factory :membership do
    user nil
    group nil
    role 'MyString'
  end
end
