# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :usage, class: Card::Usage do
    title "MyText"
    description "MyText"
  end
end
