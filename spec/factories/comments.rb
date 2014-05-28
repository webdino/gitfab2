FactoryGirl.define do
  factory :comment do |comment|
    body "MyString"
    comment.user {|u| u.association :user}
  end
end
