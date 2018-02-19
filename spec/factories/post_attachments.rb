# frozen_string_literal: true

FactoryGirl.define do
  factory :post_attachment do
    post nil
    content 'MyString'
  end
end
