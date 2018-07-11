# frozen_string_literal: true
# == Schema Information
#
# Table name: tags
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  taggable_type :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  taggable_id   :integer
#  user_id       :integer
#
# Indexes
#
#  index_tags_taggable  (taggable_type,taggable_id)
#  index_tags_user_id   (user_id)
#
# Foreign Keys
#
#  fk_tags_user_id  (user_id => users.id)
#

FactoryBot.define do
  factory :tag do
    sequence(:name) { |n| "Tag#{n}" }
    user
    association :taggable, factory: :user_project
  end
end
