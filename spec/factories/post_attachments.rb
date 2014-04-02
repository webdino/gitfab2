# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :post_attachment do
    post nil
    content "MyString"
  end
end
