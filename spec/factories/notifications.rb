# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :notification do
    notifier nil
    notified nil
    notificatable_url nil
    notificatable_type nil
    body nil
    was_read false
  end
end
