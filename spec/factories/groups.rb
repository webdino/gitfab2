# frozen_string_literal: true
# == Schema Information
#
# Table name: groups
#
#  id             :integer          not null, primary key
#  avatar         :string(255)
#  location       :string(255)
#  name           :string(255)
#  projects_count :integer          default(0), not null
#  slug           :string(255)
#  url            :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#
# Indexes
#
#  index_users_on_name  (name) UNIQUE
#  index_users_on_slug  (slug) UNIQUE
#

FactoryBot.define do
  factory :group do
    name { "group#{SecureRandom.hex 10}" }
  end
end
