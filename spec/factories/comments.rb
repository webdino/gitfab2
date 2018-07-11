# frozen_string_literal: true
# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  body             :text(65535)
#  commentable_type :string(255)      not null
#  oldid            :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  commentable_id   :integer          not null
#  user_id          :integer          not null
#
# Indexes
#
#  index_comments_commentable  (commentable_type,commentable_id)
#  index_comments_created_at   (created_at)
#  index_comments_user_id      (user_id)
#
# Foreign Keys
#
#  fk_comments_user_id  (user_id => users.id)
#

FactoryBot.define do
  factory :comment do
    sequence(:body) { |n| "Comment##{n}" }
    association :user

    after(:build) do |comment|
      # TODO: comment.commentable がnil を許容するかどうか要検討
      commentable = comment.commentable || FactoryBot.build(:user_project)
      commentable.comments << comment
      commentable.save!
    end
  end
end
