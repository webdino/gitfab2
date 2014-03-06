# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :recipe do
    title "MyString"
    description "MyText"
    user nil
  end
end
