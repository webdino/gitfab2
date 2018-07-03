# frozen_string_literal: true

FactoryBot.define do
  factory :notification do
    association :notifier, factory: :user
    association :notified, factory: :user
    notificatable_url "https://example.com"
    notificatable_type { Project.name }
    body "notification body"
    was_read false
  end
end
