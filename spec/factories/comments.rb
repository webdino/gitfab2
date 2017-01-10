FactoryGirl.define do
  factory :comment do |comment|
    sequence(:body) { |n| "Comment##{n}" }
    association :user

    after(:build) do |comment|
      commentable = comment.commentable || FactoryGirl.build(:user_project)
      commentable.comments << comment
      commentable.save!
    end
  end
end
