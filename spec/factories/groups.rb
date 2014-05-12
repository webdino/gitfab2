# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :group do |group|
    name {"group_#{SecureRandom.hex 10}"}
  end
end
