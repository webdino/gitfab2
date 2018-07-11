# frozen_string_literal: true
# == Schema Information
#
# Table name: likes
#
#  id         :integer          not null, primary key
#  oldid      :string(255)
#  created_at :datetime
#  updated_at :datetime
#  project_id :integer          not null
#  user_id    :integer          not null
#
# Indexes
#
#  index_likes_likable   (project_id)
#  index_likes_liker_id  (user_id)
#  index_likes_unique    (project_id,user_id) UNIQUE
#
# Foreign Keys
#
#  fk_likes_liker_id  (user_id => users.id)
#

FactoryBot.define do
  factory :like do
    user
    project
  end
end
