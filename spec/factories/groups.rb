# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :group do |group|
    name {SecureRandom.uuid}
    group.creator {|o| o.association :user}
  end
end
