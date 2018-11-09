FactoryBot.define do
  factory :user_password_auth, class: "User::PasswordAuth" do
    name { "user-#{SecureRandom.uuid}" }
    sequence(:email) { |i| "sample#{i}@example.com" }
    sequence(:email_confirmation) { |i| "sample#{i}@example.com" }
    password { "123456" }
    password_confirmation { "123456" }
  end
end
