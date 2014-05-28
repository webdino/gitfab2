# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project do
    name {"project-#{SecureRandom.hex 10}"}
    title {SecureRandom.uuid}
    description {SecureRandom.uuid}

    factory :user_project, class: Project do |up|
      up.owner {|o| o.association :user}
    end

    factory :group_project, class: Project do |gp|
      gp.owner {|o| o.association :group}
    end
  end
end
