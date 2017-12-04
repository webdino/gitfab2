FactoryGirl.define do
  factory :comment do |comment|
    sequence(:body) { |n| "Comment##{n}" }
    association :user

    after(:build) do |comment|
      # TODO: comment.commentable がnil を許容するかどうか要検討
      commentable = comment.commentable || FactoryGirl.build(:user_project)
      commentable.comments << comment
      commentable.save!
    end
  end
end
