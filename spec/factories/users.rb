# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    name {SecureRandom.uuid}
    email {"#{SecureRandom.uuid}@example.com"}
    password "password"
  end
end
