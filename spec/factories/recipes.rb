# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :recipe do
    name {SecureRandom.uuid}
    title {SecureRandom.uuid}
    description {SecureRandom.uuid}
    user nil
  end
end
