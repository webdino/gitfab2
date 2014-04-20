# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :recipe do
    name {SecureRandom.uuid}
    title {SecureRandom.uuid}
    description {SecureRandom.uuid}

    factory :user_recipe, class: Recipe do |ur|
      ur.owner {|o| o.association :user}
    end

    factory :group_recipe, class: Recipe do |gr|
      gr.owner {|o| o.association :group}
    end
  end
end
