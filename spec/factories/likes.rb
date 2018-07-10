# frozen_string_literal: true

# == Schema Information
#
# Table name: likes
#
#  id           :integer          not null, primary key
#  likable_type :string(255)      not null
#  oldid        :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  likable_id   :integer          not null
#  liker_id     :integer          not null
#
# Indexes
#
#  index_likes_likable   (likable_type,likable_id)
#  index_likes_liker_id  (liker_id)
#  index_likes_unique    (likable_type,likable_id,liker_id) UNIQUE
#
# Foreign Keys
#
#  fk_likes_liker_id  (liker_id => users.id)
#


FactoryBot.define do
  factory :like do
    association :liker, factory: :user
    association :likable, factory: :user_project
  end
end
