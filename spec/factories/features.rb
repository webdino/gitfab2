# frozen_string_literal: true

# == Schema Information
#
# Table name: features
#
#  id         :integer          not null, primary key
#  category   :integer          default(0), not null
#  class_name :string(255)
#  name       :string(255)      not null
#  oldid      :string(255)
#  created_at :datetime
#  updated_at :datetime
#


FactoryBot.define do
  factory :feature do
    sequence(:name) { |n| "feature#{n}" }
  end
end
