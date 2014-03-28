# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :way do
    name "MyString"
    description "MyText"
    recipe_id nil
  end
end
