# frozen_string_literal: true
# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  authority       :string(255)
#  avatar          :string(255)
#  email           :string(255)      not null
#  location        :string(255)
#  name            :string(255)
#  password_digest :string(255)
#  projects_count  :integer          default(0), not null
#  slug            :string(255)
#  url             :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#  index_users_on_name   (name) UNIQUE
#  index_users_on_slug   (slug) UNIQUE
#

FactoryBot.define do
  factory :user do
    name { "user-#{SecureRandom.hex 10}" }
    sequence(:email) { |i| "sample#{i}@example.com" }
    sequence(:email_confirmation) { |i| "sample#{i}@example.com" }
  end

  factory :administrator, parent: :user do
    authority { 'admin' }
  end
end
