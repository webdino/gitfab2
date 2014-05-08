# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :recipe do
    name {"recipe_#{SecureRandom.hex 10}"}
    title {SecureRandom.uuid}
    description {SecureRandom.uuid}
    photo Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, "/spec/assets/images/image.jpg")))

    factory :user_recipe, class: Recipe do |ur|
      ur.owner {|o| o.association :user}
    end

    factory :group_recipe, class: Recipe do |gr|
      gr.owner {|o| o.association :group}
    end
  end
end
