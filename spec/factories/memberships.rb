# frozen_string_literal: true

FactoryGirl.define do
  factory :membership do
    user nil
    group nil
    role 'MyString'
  end
end
