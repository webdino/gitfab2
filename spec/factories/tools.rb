# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tool do
    name "MyString"
    url "MyString"
    photo "MyString"
    description "MyText"
    recipe nil
  end
end
