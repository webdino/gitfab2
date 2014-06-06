# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    name {"user-#{SecureRandom.hex 10}"}
    email {"#{SecureRandom.uuid}@example.com"}
    password "password"
  end
end
